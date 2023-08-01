// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
extension Array {
    public func filterDuplicates<E: Equatable>(_ filter:(Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key){
                result.append(value)
            }
        }
        return result
    }
    
    public func split(intoChunksOf chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            let endIndex = ($0.advanced(by: chunkSize) > self.count) ? self.count - $0 : chunkSize
            return Array(self[$0..<$0.advanced(by: endIndex)])
        }
    }
}
