// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import Foundation

// MARK: - Mocked

protocol Mocked { static var mockValue: Self { get } }

func any<R: Mocked>() -> R { R.mockValue }
func any<R: FixedWidthInteger>() -> R { unsafeBitCast(0, to: R.self) }
func any<R>() -> [R] { [] }
func any<K: Hashable, V>() -> [K: V] { [:] }
func any() -> Any { 0 }
func any() -> Float { 0 }
func any() -> Double { 0 }
func any() -> String { "" }
func any() -> Data { Data() }

// MARK: - Mock<T>

public class Mock<T> {
    private let functionHandler: MockFunctionHandler
    internal let functionConsumer: FunctionConsumer
    
    internal required init(functionHandler: MockFunctionHandler? = nil) {
        self.functionConsumer = FunctionConsumer()
        self.functionHandler = (functionHandler ?? self.functionConsumer)
    }
    
    @discardableResult internal func accept(funcName: String = #function, args: [Any?] = []) -> Any? {
        return accept(funcName: funcName, checkArgs: args, actionArgs: args)
    }
    
    @discardableResult internal func accept(funcName: String = #function, checkArgs: [Any?], actionArgs: [Any?]) -> Any? {
        return functionHandler.accept(funcName, parameterSummary: summary(for: checkArgs), actionArgs: actionArgs)
    }
    
    internal func when<R>(_ callBlock: @escaping (T) throws -> R) -> MockFunctionBuilder<T, R> {
        let builder: MockFunctionBuilder<T, R> = MockFunctionBuilder(callBlock, mockInit: type(of: self).init)
        functionConsumer.functionBuilders.append(builder.build)
        
        return builder
    }
    
    private func summary(for argument: Any) -> String {
        switch argument {
            case let string as String: return string
            case let array as [Any]: return "[\(array.map { summary(for: $0) }.joined(separator: ", "))]"
                
            case let dict as [String: Any]:
                return "[\(dict.map { key, value in "\(summary(for: key)):\(summary(for: value))" }.joined(separator: ", "))]"
                
            default: return String(describing: argument)
        }
    }
}

// MARK: - MockFunctionHandler

protocol MockFunctionHandler {
    func accept(_ functionName: String, parameterSummary: String, actionArgs: [Any?]) -> Any?
}

// MARK: - MockFunction

internal class MockFunction {
    var name: String
    var parameterSummary: String
    var actions: [([Any?]) -> Void]
    var returnValue: Any?
    
    init(name: String, parameterSummary: String, actions: [([Any?]) -> Void], returnValue: Any?) {
        self.name = name
        self.parameterSummary = parameterSummary
        self.actions = actions
        self.returnValue = returnValue
    }
}

// MARK: - MockFunctionBuilder

internal class MockFunctionBuilder<T, R>: MockFunctionHandler {
    private let callBlock: (T) throws -> R
    private let mockInit: (MockFunctionHandler?) -> Mock<T>
    private var functionName: String?
    private var parameterSummary: String?
    private var actions: [([Any?]) -> Void] = []
    private var returnValue: R?
    internal var returnValueGenerator: ((String, String) -> R?)?
    
    // MARK: - Initialization
    
    init(_ callBlock: @escaping (T) throws -> R, mockInit: @escaping (MockFunctionHandler?) -> Mock<T>) {
        self.callBlock = callBlock
        self.mockInit = mockInit
    }
    
    // MARK: - Behaviours
    
    @discardableResult func then(_ block: @escaping ([Any?]) -> Void) -> MockFunctionBuilder<T, R> {
        actions.append(block)
        return self
    }
    
    func thenReturn(_ value: R?) {
        returnValue = value
    }
    
    // MARK: - MockFunctionHandler
    
    func accept(_ functionName: String, parameterSummary: String, actionArgs: [Any?]) -> Any? {
        self.functionName = functionName
        self.parameterSummary = parameterSummary
        return (returnValue ?? returnValueGenerator?(functionName, parameterSummary))
    }
    
    // MARK: - Build
    
    func build() throws -> MockFunction {
        let completionMock = mockInit(self) as! T
        _ = try callBlock(completionMock)
        
        guard let name: String = functionName, let parameterSummary: String = parameterSummary else {
            preconditionFailure("Attempted to build the MockFunction before it was called")
        }
        
        return MockFunction(name: name, parameterSummary: parameterSummary, actions: actions, returnValue: returnValue)
    }
}

// MARK: - FunctionConsumer

internal class FunctionConsumer: MockFunctionHandler {
    var trackCalls: Bool = true
    var functionBuilders: [() throws -> MockFunction?] = []
    var functionHandlers: [String: [String: MockFunction]] = [:]
    var calls: [String: [String]] = [:]
    
    func accept(_ functionName: String, parameterSummary: String, actionArgs: [Any?]) -> Any? {
        if !functionBuilders.isEmpty {
            functionBuilders
                .compactMap { try? $0() }
                .forEach { function in
                    functionHandlers[function.name] = (functionHandlers[function.name] ?? [:])
                        .setting(function.parameterSummary, function)
                }
            
            functionBuilders.removeAll()
        }
        
        guard let expectation: MockFunction = firstFunction(for: functionName, matchingParameterSummaryIfPossible: parameterSummary) else {
            preconditionFailure("No expectations found for \(functionName)")
        }
        
        // Record the call so it can be validated later (assuming we are tracking calls)
        if trackCalls {
            calls[functionName] = (calls[functionName] ?? []).appending(parameterSummary)
        }
        
        for action in expectation.actions {
            action(actionArgs)
        }

        return expectation.returnValue
    }
    
    func firstFunction(for name: String, matchingParameterSummaryIfPossible parameterSummary: String) -> MockFunction? {
        guard let possibleExpectations: [String: MockFunction] = functionHandlers[name] else { return nil }
        
        guard let expectation: MockFunction = possibleExpectations[parameterSummary] else {
            // A `nil` response might be value but in a lot of places we will need to force-cast
            // so try to find a non-nil response first
            return (
                possibleExpectations.values.first(where: { $0.returnValue != nil }) ??
                possibleExpectations.values.first
            )
        }
        
        return expectation
    }
}
