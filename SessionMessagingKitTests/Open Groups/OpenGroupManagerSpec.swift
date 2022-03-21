// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import PromiseKit
import Sodium
import SessionSnodeKit

import Quick
import Nimble

@testable import SessionMessagingKit

// MARK: - OpenGroupManagerSpec

class OpenGroupManagerSpec: QuickSpec {
    class TestCapabilitiesAndRoomApi: TestOnionRequestAPI {
        static let capabilitiesData: OpenGroupAPI.Capabilities = OpenGroupAPI.Capabilities(capabilities: [.sogs], missing: nil)
        static let roomData: OpenGroupAPI.Room = OpenGroupAPI.Room(
            token: "test",
            name: "test",
            roomDescription: nil,
            infoUpdates: 10,
            messageSequence: 0,
            created: 0,
            activeUsers: 0,
            activeUsersCutoff: 0,
            imageId: nil,
            pinnedMessages: nil,
            admin: false,
            globalAdmin: false,
            admins: [],
            hiddenAdmins: nil,
            moderator: false,
            globalModerator: false,
            moderators: [],
            hiddenModerators: nil,
            read: false,
            defaultRead: nil,
            defaultAccessible: nil,
            write: false,
            defaultWrite: nil,
            upload: false,
            defaultUpload: nil
        )
        
        override class var mockResponse: Data? {
            let responses: [Data] = [
                try! JSONEncoder().encode(
                    OpenGroupAPI.BatchSubResponse(
                        code: 200,
                        headers: [:],
                        body: capabilitiesData,
                        failedToParseBody: false
                    )
                ),
                try! JSONEncoder().encode(
                    OpenGroupAPI.BatchSubResponse(
                        code: 200,
                        headers: [:],
                        body: roomData,
                        failedToParseBody: false
                    )
                )
            ]
            
            return "[\(responses.map { String(data: $0, encoding: .utf8)! }.joined(separator: ","))]".data(using: .utf8)
        }
    }
    
    // MARK: - Spec

    override func spec() {
        var mockOGMCache: MockOGMCache!
        var mockIdentityManager: MockIdentityManager!
        var mockStorage: MockStorage!
        var mockSodium: MockSodium!
        var mockAeadXChaCha20Poly1305Ietf: MockAeadXChaCha20Poly1305Ietf!
        var mockGenericHash: MockGenericHash!
        var mockSign: MockSign!
        var mockNonce16Generator: MockNonce16Generator!
        var mockNonce24Generator: MockNonce24Generator!
        var mockUserDefaults: MockUserDefaults!
        var dependencies: OpenGroupManager.OGMDependencies!
        
        var testInteraction: TestInteraction!
        var testIncomingMessage: TestIncomingMessage!
        var testGroupThread: TestGroupThread!
        var testContactThread: TestContactThread!
        var testTransaction: TestTransaction!
        var testOpenGroup: OpenGroup!
        var testPollInfo: OpenGroupAPI.RoomPollInfo!
        var testMessage: OpenGroupAPI.Message!
        var testDirectMessage: OpenGroupAPI.DirectMessage!
        
        var cache: OpenGroupManager.Cache!
        var openGroupManager: OpenGroupManager!

        describe("an OpenGroupManager") {
            // MARK: - Configuration
            
            beforeEach {
                mockOGMCache = MockOGMCache()
                mockIdentityManager = MockIdentityManager()
                mockStorage = MockStorage()
                mockSodium = MockSodium()
                mockAeadXChaCha20Poly1305Ietf = MockAeadXChaCha20Poly1305Ietf()
                mockGenericHash = MockGenericHash()
                mockSign = MockSign()
                mockNonce16Generator = MockNonce16Generator()
                mockNonce24Generator = MockNonce24Generator()
                mockUserDefaults = MockUserDefaults()
                dependencies = OpenGroupManager.OGMDependencies(
                    cache: Atomic(mockOGMCache),
                    onionApi: TestCapabilitiesAndRoomApi.self,
                    identityManager: mockIdentityManager,
                    storage: mockStorage,
                    sodium: mockSodium,
                    genericHash: mockGenericHash,
                    sign: mockSign,
                    aeadXChaCha20Poly1305Ietf: mockAeadXChaCha20Poly1305Ietf,
                    ed25519: MockEd25519(),
                    nonceGenerator16: mockNonce16Generator,
                    nonceGenerator24: mockNonce24Generator,
                    standardUserDefaults: mockUserDefaults,
                    date: Date(timeIntervalSince1970: 1234567890)
                )
                testInteraction = TestInteraction()
                testInteraction.mockData[.uniqueId] = "TestInteractionId"
                testInteraction.mockData[.timestamp] = UInt64(123)
                
                testIncomingMessage = TestIncomingMessage(uniqueId: "TestMessageId")
                testIncomingMessage.openGroupServerMessageID = 127
                
                testGroupThread = TestGroupThread()
                testGroupThread.mockData[.uniqueId] = "TestGroupId"
                testGroupThread.mockData[.groupModel] = TSGroupModel(
                    title: "TestTitle",
                    memberIds: [],
                    image: nil,
                    groupId: LKGroupUtilities.getEncodedOpenGroupIDAsData("testServer.testRoom"),
                    groupType: .openGroup,
                    adminIds: [],
                    moderatorIds: []
                )
                testGroupThread.mockData[.interactions] = [testInteraction, testIncomingMessage]
                
                testContactThread = TestContactThread()
                testContactThread.mockData[.uniqueId] = "TestContactId"
                testContactThread.mockData[.interactions] = [testInteraction, testIncomingMessage]
                
                testTransaction = TestTransaction()
                testTransaction.mockData[.objectForKey] = testGroupThread
                
                testOpenGroup = OpenGroup(
                    server: "testServer",
                    room: "testRoom",
                    publicKey: TestConstants.publicKey,
                    name: "Test",
                    groupDescription: nil,
                    imageID: nil,
                    infoUpdates: 10
                )
                testPollInfo = OpenGroupAPI.RoomPollInfo(
                    token: "testRoom",
                    activeUsers: 10,
                    admin: false,
                    globalAdmin: false,
                    moderator: false,
                    globalModerator: false,
                    read: false,
                    defaultRead: nil,
                    defaultAccessible: nil,
                    write: false,
                    defaultWrite: nil,
                    upload: false,
                    defaultUpload: nil,
                    details: TestCapabilitiesAndRoomApi.roomData
                )
                testMessage = OpenGroupAPI.Message(
                    id: 127,
                    sender: "05\(TestConstants.publicKey)",
                    posted: 123,
                    edited: nil,
                    seqNo: 124,
                    whisper: false,
                    whisperMods: false,
                    whisperTo: nil,
                    base64EncodedData: [
                        "Cg0KC1Rlc3RNZXNzYWdlg",
                        "AAAAAAAAAAAAAAAAAAAAA",
                        "AAAAAAAAAAAAAAAAAAAAA",
                        "AAAAAAAAAAAAAAAAAAAAA",
                        "AAAAAAAAAAAAAAAAAAAAA",
                        "AAAAAAAAAAAAAAAAAAAAA",
                        "AAAAAAAAAAAAAAAAAAAAA",
                        "AAAAAAAAAAAAAAAAAAAAA",
                        "AAAAAAAAAAAAAAAAAAAAA",
                        "AAAAAAAAAAAAAAAAAAAAA",
                        "AA"
                    ].joined(),
                    base64EncodedSignature: nil
                )
                testDirectMessage = OpenGroupAPI.DirectMessage(
                    id: 128,
                    sender: "15\(TestConstants.publicKey)",
                    recipient: "15\(TestConstants.publicKey)",
                    posted: 1234567890,
                    expires: 1234567990,
                    base64EncodedMessage: Data(
                        Bytes(arrayLiteral: 0) +
                        "TestMessage".bytes +
                        Data(base64Encoded: "pbTUizreT0sqJ2R2LloseQDyVL2RYztD")!.bytes
                    ).base64EncodedString()
                )
                
                mockIdentityManager
                    .when { $0.identityKeyPair() }
                    .thenReturn(
                        try! ECKeyPair(
                            publicKeyData: Data.data(fromHex: TestConstants.publicKey)!,
                            privateKeyData: Data.data(fromHex: TestConstants.privateKey)!
                        )
                    )
                mockStorage
                    .when { $0.write(with: { _ in }) }
                    .then { [testTransaction] args in (args.first as? ((Any) -> Void))?(testTransaction! as Any) }
                    .thenReturn(Promise.value(()))
                mockStorage
                    .when { $0.write(with: { _ in }, completion: { }) }
                    .then { [testTransaction] args in
                        (args.first as? ((Any) -> Void))?(testTransaction! as Any)
                        (args.last as? (() -> Void))?()
                    }
                    .thenReturn(Promise.value(()))
                mockStorage
                    .when { $0.getUserKeyPair() }
                    .thenReturn(
                        try! ECKeyPair(
                            publicKeyData: Data.data(fromHex: TestConstants.publicKey)!,
                            privateKeyData: Data.data(fromHex: TestConstants.privateKey)!
                        )
                    )
                mockStorage
                    .when { $0.getUserED25519KeyPair() }
                    .thenReturn(
                        Box.KeyPair(
                            publicKey: Data.data(fromHex: TestConstants.publicKey)!.bytes,
                            secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                        )
                    )
                mockStorage
                    .when { $0.getAllOpenGroups() }
                    .thenReturn([
                        "0": testOpenGroup
                    ])
                mockStorage
                    .when { $0.getOpenGroup(for: any()) }
                    .thenReturn(testOpenGroup)
                mockStorage
                    .when { $0.getOpenGroupServer(name: any()) }
                    .thenReturn(
                        OpenGroupAPI.Server(
                            name: "testServer",
                            capabilities: OpenGroupAPI.Capabilities(capabilities: [.sogs], missing: [])
                        )
                    )
                mockStorage
                    .when { $0.getOpenGroupPublicKey(for: any()) }
                    .thenReturn(TestConstants.publicKey)
                
                mockGenericHash.when { $0.hash(message: anyArray(), outputLength: any()) }.thenReturn([])
                mockSodium
                    .when { $0.blindedKeyPair(serverPublicKey: any(), edKeyPair: any(), genericHash: mockGenericHash) }
                    .thenReturn(
                        Box.KeyPair(
                            publicKey: Data.data(fromHex: TestConstants.publicKey)!.bytes,
                            secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                        )
                    )
                mockSodium
                    .when {
                        $0.sogsSignature(
                            message: anyArray(),
                            secretKey: anyArray(),
                            blindedSecretKey: anyArray(),
                            blindedPublicKey: anyArray()
                        )
                    }
                    .thenReturn("TestSogsSignature".bytes)
                mockSign.when { $0.signature(message: anyArray(), secretKey: anyArray()) }.thenReturn("TestSignature".bytes)
                
                mockNonce16Generator
                    .when { $0.nonce() }
                    .thenReturn(Data(base64Encoded: "pK6YRtQApl4NhECGizF0Cg==")!.bytes)
                mockNonce24Generator
                    .when { $0.nonce() }
                    .thenReturn(Data(base64Encoded: "pbTUizreT0sqJ2R2LloseQDyVL2RYztD")!.bytes)
                
                cache = OpenGroupManager.Cache()
                openGroupManager = OpenGroupManager()
            }

            afterEach {
                OpenGroupManager.shared.stopPolling()   // Need to stop any pollers which get created during tests
                openGroupManager.stopPolling()          // Assuming it's different from the above
                
                mockOGMCache = nil
                mockStorage = nil
                mockSodium = nil
                mockAeadXChaCha20Poly1305Ietf = nil
                mockGenericHash = nil
                mockSign = nil
                mockUserDefaults = nil
                dependencies = nil
                
                testInteraction = nil
                testGroupThread = nil
                testContactThread = nil
                testTransaction = nil
                testOpenGroup = nil
                
                openGroupManager = nil
            }
            
            // MARK: - Cache
            
            context("cache data") {
                it("defaults the time since last open to greatestFiniteMagnitude") {
                    mockUserDefaults
                        .when { $0.object(forKey: SNUserDefaults.Date.lastOpen.rawValue) }
                        .thenReturn(nil)
                    
                    expect(cache.getTimeSinceLastOpen(using: dependencies))
                        .to(beCloseTo(.greatestFiniteMagnitude))
                }
                
                it("returns the time since the last open") {
                    mockUserDefaults
                        .when { $0.object(forKey: SNUserDefaults.Date.lastOpen.rawValue) }
                        .thenReturn(Date(timeIntervalSince1970: 1234567880))
                    dependencies = dependencies.with(date: Date(timeIntervalSince1970: 1234567890))
                    
                    expect(cache.getTimeSinceLastOpen(using: dependencies))
                        .to(beCloseTo(10))
                }
                
                it("caches the time since the last open") {
                    mockUserDefaults
                        .when { $0.object(forKey: SNUserDefaults.Date.lastOpen.rawValue) }
                        .thenReturn(Date(timeIntervalSince1970: 1234567770))
                    dependencies = dependencies.with(date: Date(timeIntervalSince1970: 1234567780))
                    
                    expect(cache.getTimeSinceLastOpen(using: dependencies))
                        .to(beCloseTo(10))
                    
                    mockUserDefaults
                        .when { $0.object(forKey: SNUserDefaults.Date.lastOpen.rawValue) }
                        .thenReturn(Date(timeIntervalSince1970: 1234567890))
                 
                    // Cached value shouldn't have been updated
                    expect(cache.getTimeSinceLastOpen(using: dependencies))
                        .to(beCloseTo(10))
                }
            }
            
            // MARK: - Polling
            
            context("when starting polling") {
                beforeEach {
                    mockStorage
                        .when { $0.getAllOpenGroups() }
                        .thenReturn([
                            "0": testOpenGroup,
                            "1": OpenGroup(
                                server: "testServer1",
                                room: "testRoom1",
                                publicKey: TestConstants.publicKey,
                                name: "Test1",
                                groupDescription: nil,
                                imageID: nil,
                                infoUpdates: 0
                            )
                        ])
                    mockStorage.when { $0.removeOpenGroupSequenceNumber(for: any(), on: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setOpenGroupPublicKey(for: any(), to: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setOpenGroupServer(any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setOpenGroup(any(), for: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setUserCount(to: any(), forOpenGroupWithID: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.getOpenGroupInboxLatestMessageId(for: any()) }.thenReturn(nil)
                    mockStorage.when { $0.getOpenGroupOutboxLatestMessageId(for: any()) }.thenReturn(nil)
                    mockStorage.when { $0.getOpenGroupSequenceNumber(for: any(), on: any()) }.thenReturn(nil)
                    
                    mockOGMCache.when { $0.hasPerformedInitialPoll }.thenReturn([:])
                    mockOGMCache.when { $0.timeSinceLastPoll }.thenReturn([:])
                    mockOGMCache.when { $0.getTimeSinceLastOpen(using: dependencies) }.thenReturn(0)
                    mockOGMCache.when { $0.isPolling }.thenReturn(false)
                    mockOGMCache.when { $0.pollers }.thenReturn([:])
                    
                    mockUserDefaults
                        .when { $0.object(forKey: SNUserDefaults.Date.lastOpen.rawValue) }
                        .thenReturn(Date(timeIntervalSince1970: 1234567890))
                }
                
                it("creates pollers for all of the open groups") {
                    openGroupManager.startPolling(using: dependencies)
                    
                    expect(mockOGMCache)
                        .to(call(matchingParameters: true) {
                            $0.pollers = [
                                "testserver": OpenGroupAPI.Poller(for: "testserver"),
                                "testserver1": OpenGroupAPI.Poller(for: "testserver1")
                            ]
                        })
                }
                
                it("updates the isPolling flag") {
                    openGroupManager.startPolling(using: dependencies)
                    
                    expect(mockOGMCache).to(call(matchingParameters: true) { $0.isPolling = true })
                }
                
                it("does nothing if already polling") {
                    mockOGMCache.when { $0.isPolling }.thenReturn(true)
                    
                    openGroupManager.startPolling(using: dependencies)
                    
                    expect(mockOGMCache).toNot(call { $0.pollers })
                }
            }
            
            context("when stopping polling") {
                beforeEach {
                    mockStorage
                        .when { $0.getAllOpenGroups() }
                        .thenReturn([
                            "0": testOpenGroup,
                            "1": OpenGroup(
                                server: "testServer1",
                                room: "testRoom1",
                                publicKey: TestConstants.publicKey,
                                name: "Test1",
                                groupDescription: nil,
                                imageID: nil,
                                infoUpdates: 0
                            )
                        ])
                    mockStorage.when { $0.removeOpenGroupSequenceNumber(for: any(), on: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setOpenGroupPublicKey(for: any(), to: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setOpenGroupServer(any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setOpenGroup(any(), for: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setUserCount(to: any(), forOpenGroupWithID: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.getOpenGroupInboxLatestMessageId(for: any()) }.thenReturn(nil)
                    mockStorage.when { $0.getOpenGroupOutboxLatestMessageId(for: any()) }.thenReturn(nil)
                    mockStorage.when { $0.getOpenGroupSequenceNumber(for: any(), on: any()) }.thenReturn(nil)
                    
                    mockOGMCache.when { $0.isPolling }.thenReturn(true)
                    mockOGMCache.when { $0.pollers }.thenReturn(["testserver": OpenGroupAPI.Poller(for: "testserver")])
                    
                    mockUserDefaults
                        .when { $0.object(forKey: SNUserDefaults.Date.lastOpen.rawValue) }
                        .thenReturn(Date(timeIntervalSince1970: 1234567890))
                    
                    openGroupManager.startPolling(using: dependencies)
                }
                
                it("removes all pollers") {
                    openGroupManager.stopPolling(using: dependencies)
                    
                    expect(mockOGMCache).to(call(matchingParameters: true) { $0.pollers = [:] })
                }
                
                it("updates the isPolling flag") {
                    openGroupManager.stopPolling(using: dependencies)
                    
                    expect(mockOGMCache).to(call(matchingParameters: true) { $0.isPolling = false })
                }
            }
            
            // MARK: - Adding & Removing
            
            // MARK: - --hasExistingOpenGroup
            
            context("when checking it has an existing open group") {
                context("when there is a thread for the room and the cache has a poller") {
                    beforeEach {
                        testTransaction.mockData[.objectForKey] = testGroupThread
                    }
                    
                    context("for the no-scheme variant") {
                        beforeEach {
                            mockOGMCache.when { $0.pollers }.thenReturn(["testServer": OpenGroupAPI.Poller(for: "testServer")])
                        }
                        
                        it("returns true when no scheme is provided") {
                            expect(
                                openGroupManager
                                    .hasExistingOpenGroup(
                                        roomToken: "testRoom",
                                        server: "testServer",
                                        publicKey: "testKey",
                                        using: testTransaction,
                                        dependencies: dependencies
                                    )
                            ).to(beTrue())
                        }
                        
                        it("returns true when a http scheme is provided") {
                            expect(
                                openGroupManager
                                    .hasExistingOpenGroup(
                                        roomToken: "testRoom",
                                        server: "http://testServer",
                                        publicKey: "testKey",
                                        using: testTransaction,
                                        dependencies: dependencies
                                    )
                            ).to(beTrue())
                        }
                        
                        it("returns true when a https scheme is provided") {
                            expect(
                                openGroupManager
                                    .hasExistingOpenGroup(
                                        roomToken: "testRoom",
                                        server: "https://testServer",
                                        publicKey: "testKey",
                                        using: testTransaction,
                                        dependencies: dependencies
                                    )
                            ).to(beTrue())
                        }
                    }
                    
                    context("for the http variant") {
                        beforeEach {
                            mockOGMCache.when { $0.pollers }.thenReturn(["http://testServer": OpenGroupAPI.Poller(for: "http://testServer")])
                        }
                        
                        it("returns true when no scheme is provided") {
                            expect(
                                openGroupManager
                                    .hasExistingOpenGroup(
                                        roomToken: "testRoom",
                                        server: "testServer",
                                        publicKey: "testKey",
                                        using: testTransaction,
                                        dependencies: dependencies
                                    )
                            ).to(beTrue())
                        }
                        
                        it("returns true when a http scheme is provided") {
                            expect(
                                openGroupManager
                                    .hasExistingOpenGroup(
                                        roomToken: "testRoom",
                                        server: "http://testServer",
                                        publicKey: "testKey",
                                        using: testTransaction,
                                        dependencies: dependencies
                                    )
                            ).to(beTrue())
                        }
                        
                        it("returns true when a https scheme is provided") {
                            expect(
                                openGroupManager
                                    .hasExistingOpenGroup(
                                        roomToken: "testRoom",
                                        server: "https://testServer",
                                        publicKey: "testKey",
                                        using: testTransaction,
                                        dependencies: dependencies
                                    )
                            ).to(beTrue())
                        }
                    }
                    
                    context("for the https variant") {
                        beforeEach {
                            mockOGMCache.when { $0.pollers }.thenReturn(["https://testServer": OpenGroupAPI.Poller(for: "https://testServer")])
                        }
                        
                        it("returns true when no scheme is provided") {
                            expect(
                                openGroupManager
                                    .hasExistingOpenGroup(
                                        roomToken: "testRoom",
                                        server: "testServer",
                                        publicKey: "testKey",
                                        using: testTransaction,
                                        dependencies: dependencies
                                    )
                            ).to(beTrue())
                        }
                        
                        it("returns true when a http scheme is provided") {
                            expect(
                                openGroupManager
                                    .hasExistingOpenGroup(
                                        roomToken: "testRoom",
                                        server: "http://testServer",
                                        publicKey: "testKey",
                                        using: testTransaction,
                                        dependencies: dependencies
                                    )
                            ).to(beTrue())
                        }
                        
                        it("returns true when a https scheme is provided") {
                            expect(
                                openGroupManager
                                    .hasExistingOpenGroup(
                                        roomToken: "testRoom",
                                        server: "https://testServer",
                                        publicKey: "testKey",
                                        using: testTransaction,
                                        dependencies: dependencies
                                    )
                            ).to(beTrue())
                        }
                    }
                }
                
                context("when given the legacy DNS host and there is a cached poller for the default server") {
                    it("returns true") {
                        mockOGMCache.when { $0.pollers }.thenReturn(["http://116.203.70.33": OpenGroupAPI.Poller(for: "http://116.203.70.33")])
                        testTransaction.mockData[.objectForKey] = testGroupThread
                        
                        expect(
                            openGroupManager
                                .hasExistingOpenGroup(
                                    roomToken: "testRoom",
                                    server: "http://open.getsession.org",
                                    publicKey: "testKey",
                                    using: testTransaction,
                                    dependencies: dependencies
                                )
                        ).to(beTrue())
                    }
                }
                
                context("when given the default server and there is a cached poller for the legacy DNS host") {
                    it("returns true") {
                        mockOGMCache.when { $0.pollers }.thenReturn(["http://open.getsession.org": OpenGroupAPI.Poller(for: "http://open.getsession.org")])
                        testTransaction.mockData[.objectForKey] = testGroupThread
                        
                        expect(
                            openGroupManager
                                .hasExistingOpenGroup(
                                    roomToken: "testRoom",
                                    server: "http://116.203.70.33",
                                    publicKey: "testKey",
                                    using: testTransaction,
                                    dependencies: dependencies
                                )
                        ).to(beTrue())
                    }
                }
                
                it("returns false when given an invalid server") {
                    mockOGMCache.when { $0.pollers }.thenReturn(["testServer": OpenGroupAPI.Poller(for: "testServer")])
                    testTransaction.mockData[.objectForKey] = testGroupThread
                    
                    expect(
                        openGroupManager
                            .hasExistingOpenGroup(
                                roomToken: "testRoom",
                                server: "%%%",
                                publicKey: "testKey",
                                using: testTransaction,
                                dependencies: dependencies
                            )
                    ).to(beFalse())
                }
                
                it("returns false if there is not a poller for the server in the cache") {
                    mockOGMCache.when { $0.pollers }.thenReturn([:])
                    testTransaction.mockData[.objectForKey] = testGroupThread
                    
                    expect(
                        openGroupManager
                            .hasExistingOpenGroup(
                                roomToken: "testRoom",
                                server: "testServer",
                                publicKey: "testKey",
                                using: testTransaction,
                                dependencies: dependencies
                            )
                    ).to(beFalse())
                }
                
                it("returns false if there is a poller for the server in the cache but no thread for the room") {
                    mockOGMCache.when { $0.pollers }.thenReturn(["testServer": OpenGroupAPI.Poller(for: "testServer")])
                    testTransaction.mockData[.objectForKey] = nil
                    
                    expect(
                        openGroupManager
                            .hasExistingOpenGroup(
                                roomToken: "testRoom",
                                server: "testServer",
                                publicKey: "testKey",
                                using: testTransaction,
                                dependencies: dependencies
                            )
                    ).to(beFalse())
                }
            }
            
            // MARK: - --add
            
            context("when adding") {
                beforeEach {
                    mockStorage.when { $0.removeOpenGroupSequenceNumber(for: any(), on: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setOpenGroupPublicKey(for: any(), to: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setOpenGroupServer(any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setOpenGroup(any(), for: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setUserCount(to: any(), forOpenGroupWithID: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.getOpenGroupInboxLatestMessageId(for: any()) }.thenReturn(nil)
                    mockStorage.when { $0.getOpenGroupOutboxLatestMessageId(for: any()) }.thenReturn(nil)
                    mockStorage.when { $0.getOpenGroupSequenceNumber(for: any(), on: any()) }.thenReturn(nil)
                    
                    mockOGMCache.when { $0.pollers }.thenReturn([:])
                    mockOGMCache.when { $0.moderators }.thenReturn([:])
                    mockOGMCache.when { $0.admins }.thenReturn([:])
                    
                    mockUserDefaults
                        .when { $0.object(forKey: SNUserDefaults.Date.lastOpen.rawValue) }
                        .thenReturn(Date(timeIntervalSince1970: 1234567890))
                }
                
                it("resets the sequence number of the open group") {
                    var didComplete: Bool = false   // Prevent multi-threading test bugs
                    
                    openGroupManager
                        .add(
                            roomToken: "testRoom",
                            server: "testServer",
                            publicKey: "testKey",
                            isConfigMessage: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        .map { _ -> Void in didComplete = true }
                        .retainUntilComplete()
                    
                    expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                    expect(mockStorage)
                        .to(
                            call(.exactly(times: 1)) {
                                $0.removeOpenGroupSequenceNumber(
                                    for: "testRoom",
                                    on: "testServer",
                                    using: testTransaction! as Any
                                )
                            }
                        )
                }
                
                it("sets the public key of the open group server") {
                    var didComplete: Bool = false   // Prevent multi-threading test bugs
                    
                    openGroupManager
                        .add(
                            roomToken: "testRoom",
                            server: "testServer",
                            publicKey: "testKey",
                            isConfigMessage: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        .map { _ -> Void in didComplete = true }
                        .retainUntilComplete()
                    
                    expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                    expect(mockStorage)
                        .to(
                            call(.exactly(times: 1)) {
                                $0.setOpenGroupPublicKey(
                                    for: "testRoom",
                                    to: "testKey",
                                    using: testTransaction! as Any
                                )
                            }
                        )
                }
                
                it("adds a poller") {
                    var didComplete: Bool = false   // Prevent multi-threading test bugs
                    
                    openGroupManager
                        .add(
                            roomToken: "testRoom",
                            server: "testServer",
                            publicKey: "testKey",
                            isConfigMessage: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        .map { _ -> Void in didComplete = true }
                        .retainUntilComplete()
                    
                    expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                    expect(mockOGMCache)
                        .toEventually(
                            call(matchingParameters: true) {
                                $0.pollers = ["testServer": OpenGroupAPI.Poller(for: "testServer")]
                            },
                            timeout: .milliseconds(50)
                        )
                }
                
                context("an existing room") {
                    beforeEach {
                        mockOGMCache.when { $0.pollers }.thenReturn(["testServer": OpenGroupAPI.Poller(for: "testServer")])
                    }
                    
                    it("does not reset the sequence number or update the public key") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        openGroupManager
                            .add(
                                roomToken: "testRoom",
                                server: "testServer",
                                publicKey: "testKey",
                                isConfigMessage: false,
                                using: testTransaction,
                                dependencies: dependencies
                            )
                            .map { _ -> Void in didComplete = true }
                            .retainUntilComplete()
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockStorage)
                            .toEventuallyNot(
                                call {
                                    $0.removeOpenGroupSequenceNumber(
                                        for: "testRoom",
                                        on: "testServer",
                                        using: testTransaction! as Any
                                    )
                                },
                                timeout: .milliseconds(50)
                            )
                        expect(mockStorage)
                            .toEventuallyNot(
                                call {
                                    $0.setOpenGroupPublicKey(
                                        for: "testRoom",
                                        to: "testKey",
                                        using: testTransaction! as Any
                                    )
                                },
                                timeout: .milliseconds(50)
                            )
                    }
                }
                
                context("with an invalid response") {
                    beforeEach {
                        class TestApi: TestOnionRequestAPI {
                            override class var mockResponse: Data? { return Data() }
                        }
                        dependencies = dependencies.with(onionApi: TestApi.self)
                        
                        mockUserDefaults
                            .when { $0.object(forKey: SNUserDefaults.Date.lastOpen.rawValue) }
                            .thenReturn(Date(timeIntervalSince1970: 1234567890))
                    }
                
                    it("fails with the error") {
                        var error: Error?
                        
                        let promise = openGroupManager
                            .add(
                                roomToken: "testRoom",
                                server: "testServer",
                                publicKey: "testKey",
                                isConfigMessage: false,
                                using: testTransaction,
                                dependencies: dependencies
                            )
                        promise.catch { error = $0 }
                        promise.retainUntilComplete()
                        
                        expect(error?.localizedDescription)
                            .toEventually(
                                equal(HTTP.Error.parsingFailed.localizedDescription),
                                timeout: .milliseconds(50)
                            )
                    }
                }
            }
            
            // MARK: - --delete
            
            context("when deleting") {
                beforeEach {
                    testGroupThread.mockData[.interactions] = [testInteraction]
                    
                    mockStorage
                        .when { $0.updateMessageIDCollectionByPruningMessagesWithIDs(anySet(), using: anyAny()) }
                        .thenReturn(())
                    mockStorage.when { $0.removeReceivedMessageTimestamps(anySet(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.removeOpenGroupSequenceNumber(for: any(), on: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.removeOpenGroup(for: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.removeOpenGroupServer(name: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.removeOpenGroupPublicKey(for: any(), using: anyAny()) }.thenReturn(())
                    
                    mockOGMCache.when { $0.pollers }.thenReturn([:])
                }
                
                it("removes messages for the given thread") {
                    openGroupManager
                        .delete(
                            testOpenGroup,
                            associatedWith: testGroupThread,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                    
                    expect(mockStorage)
                        .to(call(matchingParameters: true) {
                            $0.updateMessageIDCollectionByPruningMessagesWithIDs(
                                Set(arrayLiteral: testInteraction.uniqueId!),
                                using: testTransaction! as Any
                            )
                        })
                }
                
                it("removes received timestamps for the given thread") {
                    openGroupManager
                        .delete(
                            testOpenGroup,
                            associatedWith: testGroupThread,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                    
                    expect(mockStorage)
                        .to(call(matchingParameters: true) {
                            $0.removeReceivedMessageTimestamps(
                                Set(arrayLiteral: testInteraction.timestamp),
                                using: testTransaction! as Any
                            )
                        })
                }
                
                it("removes the sequence number for the given thread") {
                    openGroupManager
                        .delete(
                            testOpenGroup,
                            associatedWith: testGroupThread,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                    
                    expect(mockStorage)
                        .to(call(matchingParameters: true) {
                            $0.removeOpenGroupSequenceNumber(
                                for: "testRoom",
                                on: "testserver",
                                using: testTransaction! as Any
                            )
                        })
                }
                
                it("removes all interactions for the given thread") {
                    openGroupManager
                        .delete(
                            testOpenGroup,
                            associatedWith: testGroupThread,
                            using: YapDatabaseReadWriteTransaction(),
                            dependencies: dependencies
                        )
                    
                    expect(testGroupThread.didCallRemoveAllThreadInteractions).to(beTrue())
                }
                
                it("removes the given thread") {
                    openGroupManager
                        .delete(
                            testOpenGroup,
                            associatedWith: testGroupThread,
                            using: YapDatabaseReadWriteTransaction(),
                            dependencies: dependencies
                        )
                    
                    expect(testGroupThread.didCallRemove).to(beTrue())
                }
                
                it("removes the open group") {
                    openGroupManager
                        .delete(
                            testOpenGroup,
                            associatedWith: testGroupThread,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                    
                    expect(mockStorage)
                        .to(call(matchingParameters: true) {
                            $0.removeOpenGroup(
                                for: testGroupThread.uniqueId!,
                                using: testTransaction! as Any
                            )
                        })
                }
                
                context("and there is only one open group for this server") {
                    it("stops the poller") {
                        mockOGMCache.when { $0.pollers }.thenReturn(["testserver": OpenGroupAPI.Poller(for: "testserver")])
                        
                        openGroupManager
                            .delete(
                                testOpenGroup,
                                associatedWith: testGroupThread,
                                using: testTransaction,
                                dependencies: dependencies
                            )
                        
                        expect(mockOGMCache).to(call(matchingParameters: true) { $0.pollers = [:] })
                    }
                    
                    it("removes the open group server") {
                        openGroupManager
                            .delete(
                                testOpenGroup,
                                associatedWith: testGroupThread,
                                using: testTransaction,
                                dependencies: dependencies
                            )
                        
                        expect(mockStorage)
                            .to(call(matchingParameters: true) {
                                $0.removeOpenGroupServer(
                                    name: "testserver",
                                    using: testTransaction! as Any
                                )
                            })
                    }
                    
                    it("removes the open group public key") {
                        openGroupManager
                            .delete(
                                testOpenGroup,
                                associatedWith: testGroupThread,
                                using: testTransaction,
                                dependencies: dependencies
                            )
                        
                        expect(mockStorage)
                            .to(call(matchingParameters: true) {
                                $0.removeOpenGroupPublicKey(
                                    for: "testserver",
                                    using: testTransaction! as Any
                                )
                            })
                    }
                }
                
                context("and the are multiple open groups for this server") {
                    beforeEach {
                        mockStorage
                            .when { $0.getAllOpenGroups() }
                            .thenReturn([
                                "0": testOpenGroup,
                                "1": OpenGroup(
                                    server: "testServer",
                                    room: "testRoom1",
                                    publicKey: TestConstants.publicKey,
                                    name: "Test1",
                                    groupDescription: nil,
                                    imageID: nil,
                                    infoUpdates: 0
                                )
                            ])
                    }
                    
                    it("does not stop the poller") {
                        mockOGMCache.when { $0.pollers }.thenReturn(["testserver": OpenGroupAPI.Poller(for: "testserver")])
                        
                        openGroupManager
                            .delete(
                                testOpenGroup,
                                associatedWith: testGroupThread,
                                using: testTransaction,
                                dependencies: dependencies
                            )
                        
                        expect(mockOGMCache).toNot(call { $0.pollers })
                    }
                    
                    it("does not remove the open group server") {
                        openGroupManager
                            .delete(
                                testOpenGroup,
                                associatedWith: testGroupThread,
                                using: testTransaction,
                                dependencies: dependencies
                            )
                        
                        expect(mockStorage).toNot(call { $0.removeOpenGroupServer(name: any(), using: anyAny()) })
                    }
                    
                    it("does not remove the open group public key") {
                        openGroupManager
                            .delete(
                                testOpenGroup,
                                associatedWith: testGroupThread,
                                using: testTransaction,
                                dependencies: dependencies
                            )
                        
                        expect(mockStorage).toNot(call { $0.removeOpenGroupPublicKey(for: any(), using: anyAny()) })
                    }
                }
            }
            
            // MARK: - Response Processing
            
            // MARK: - --handleCapabilities
            
            context("when handling capabilities") {
                beforeEach {
                    mockStorage.when { $0.setOpenGroupServer(any(), using: anyAny()) }.thenReturn(())
                    
                    OpenGroupManager
                        .handleCapabilities(
                            OpenGroupAPI.Capabilities(capabilities: [], missing: []),
                            on: "testserver",
                            using: testTransaction,
                            dependencies: dependencies
                        )
                }
                
                it("stores the capabilities") {
                    expect(mockStorage).to(call { $0.setOpenGroupServer(any(), using: anyAny()) })
                }
            }
            
            // MARK: - --handlePollInfo
            
            context("when handling room poll info") {
                beforeEach {
                    mockStorage.when { $0.setOpenGroup(any(), for: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setOpenGroupServer(any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.setUserCount(to: any(), forOpenGroupWithID: any(), using: anyAny()) }.thenReturn(())
                    mockStorage.when { $0.getOpenGroupSequenceNumber(for: any(), on: any()) }.thenReturn(nil)
                    mockStorage.when { $0.getOpenGroupInboxLatestMessageId(for: any()) }.thenReturn(nil)
                    mockStorage.when { $0.getOpenGroupOutboxLatestMessageId(for: any()) }.thenReturn(nil)
                    
                    mockOGMCache.when { $0.pollers }.thenReturn([:])
                    mockOGMCache.when { $0.moderators }.thenReturn([:])
                    mockOGMCache.when { $0.admins }.thenReturn([:])
                    
                    mockUserDefaults
                        .when { $0.object(forKey: SNUserDefaults.Date.lastOpen.rawValue) }
                        .thenReturn(nil)
                }
                
                it("attempts to retrieve the existing thread") {
                    var didComplete: Bool = false   // Prevent multi-threading test bugs
                    
                    OpenGroupManager.handlePollInfo(
                        testPollInfo,
                        publicKey: TestConstants.publicKey,
                        for: "testRoom",
                        on: "testServer",
                        using: testTransaction,
                        dependencies: dependencies
                    ) { didComplete = true }
                    
                    expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                    expect(testGroupThread.numSaveCalls).to(equal(1))
                }
                
                it("attempts to retrieve the existing open group") {
                    var didComplete: Bool = false   // Prevent multi-threading test bugs
                    
                    OpenGroupManager.handlePollInfo(
                        testPollInfo,
                        publicKey: TestConstants.publicKey,
                        for: "testRoom",
                        on: "testServer",
                        using: testTransaction,
                        dependencies: dependencies
                    ) { didComplete = true }
                    
                    expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                    expect(mockStorage).to(call { $0.getOpenGroup(for: any()) })
                }
                
                it("saves the thread") {
                    var didComplete: Bool = false   // Prevent multi-threading test bugs
                    
                    OpenGroupManager.handlePollInfo(
                        testPollInfo,
                        publicKey: TestConstants.publicKey,
                        for: "testRoom",
                        on: "testServer",
                        using: testTransaction,
                        dependencies: dependencies
                    ) { didComplete = true }
                    
                    expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                    expect(testGroupThread.numSaveCalls).to(equal(1))
                }
                
                it("saves the open group") {
                    var didComplete: Bool = false   // Prevent multi-threading test bugs
                    
                    OpenGroupManager.handlePollInfo(
                        testPollInfo,
                        publicKey: TestConstants.publicKey,
                        for: "testRoom",
                        on: "testServer",
                        using: testTransaction,
                        dependencies: dependencies
                    ) { didComplete = true }
                    
                    expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                    expect(mockStorage).to(call { $0.setOpenGroup(any(), for: any(), using: anyAny()) })
                }
                
                it("saves the updated user count") {
                    var didComplete: Bool = false   // Prevent multi-threading test bugs
                    
                    OpenGroupManager.handlePollInfo(
                        testPollInfo,
                        publicKey: TestConstants.publicKey,
                        for: "testRoom",
                        on: "testServer",
                        using: testTransaction,
                        dependencies: dependencies
                    ) { didComplete = true }
                    
                    expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                    expect(mockStorage)
                        .to(call(matchingParameters: true) {
                            $0.setUserCount(to: 10, forOpenGroupWithID: "testServer.testRoom", using: testTransaction! as Any)
                        })
                }
                
                it("calls the completion block") {
                    var didCallComplete: Bool = false
                    
                    OpenGroupManager.handlePollInfo(
                        testPollInfo,
                        publicKey: TestConstants.publicKey,
                        for: "testRoom",
                        on: "testServer",
                        using: testTransaction,
                        dependencies: dependencies
                    ) {
                        didCallComplete = true
                    }
                    
                    expect(didCallComplete)
                        .toEventually(
                            beTrue(),
                            timeout: .milliseconds(50)
                        )
                }
                
                context("and updating the moderator list") {
                    it("successfully updates") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        mockOGMCache.when { $0.moderators }.thenReturn([:])
                        testPollInfo = OpenGroupAPI.RoomPollInfo(
                            token: "testRoom",
                            activeUsers: 10,
                            admin: false,
                            globalAdmin: false,
                            moderator: false,
                            globalModerator: false,
                            read: false,
                            defaultRead: nil,
                            defaultAccessible: nil,
                            write: false,
                            defaultWrite: nil,
                            upload: false,
                            defaultUpload: nil,
                            details: TestCapabilitiesAndRoomApi.roomData.with(moderators: ["TestMod"], admins: [])
                        )
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockOGMCache)
                            .toEventually(
                                call(matchingParameters: true) {
                                    $0.moderators = ["testServer": ["testRoom": Set(arrayLiteral: "TestMod")]]
                                },
                                timeout: .milliseconds(50)
                            )
                    }
                    
                    it("defaults to an empty array if no moderators are provided") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        mockOGMCache.when { $0.moderators }.thenReturn([:])
                        testPollInfo = OpenGroupAPI.RoomPollInfo(
                            token: "testRoom",
                            activeUsers: 10,
                            admin: false,
                            globalAdmin: false,
                            moderator: false,
                            globalModerator: false,
                            read: false,
                            defaultRead: nil,
                            defaultAccessible: nil,
                            write: false,
                            defaultWrite: nil,
                            upload: false,
                            defaultUpload: nil,
                            details: nil
                        )
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockOGMCache)
                            .toEventually(
                                call(matchingParameters: true) {
                                    $0.moderators = ["testServer": ["testRoom": Set()]]
                                },
                                timeout: .milliseconds(50)
                            )
                    }
                }
                
                context("and updating the admin list") {
                    it("successfully updates") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        mockOGMCache.when { $0.admins }.thenReturn([:])
                        testPollInfo = OpenGroupAPI.RoomPollInfo(
                            token: "testRoom",
                            activeUsers: 10,
                            admin: false,
                            globalAdmin: false,
                            moderator: false,
                            globalModerator: false,
                            read: false,
                            defaultRead: nil,
                            defaultAccessible: nil,
                            write: false,
                            defaultWrite: nil,
                            upload: false,
                            defaultUpload: nil,
                            details: TestCapabilitiesAndRoomApi.roomData.with(moderators: [], admins: ["TestAdmin"])
                        )
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockOGMCache)
                            .toEventually(
                                call(matchingParameters: true) {
                                    $0.admins = ["testServer": ["testRoom": Set(arrayLiteral: "TestAdmin")]]
                                },
                                timeout: .milliseconds(50)
                            )
                    }
                    
                    it("defaults to an empty array if no moderators are provided") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        mockOGMCache.when { $0.admins }.thenReturn([:])
                        testPollInfo = OpenGroupAPI.RoomPollInfo(
                            token: "testRoom",
                            activeUsers: 10,
                            admin: false,
                            globalAdmin: false,
                            moderator: false,
                            globalModerator: false,
                            read: false,
                            defaultRead: nil,
                            defaultAccessible: nil,
                            write: false,
                            defaultWrite: nil,
                            upload: false,
                            defaultUpload: nil,
                            details: nil
                        )
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockOGMCache)
                            .toEventually(
                                call(matchingParameters: true) {
                                    $0.admins = ["testServer": ["testRoom": Set()]]
                                },
                                timeout: .milliseconds(50)
                            )
                    }
                }
                
                context("when it cannot get the thread id") {
                    it("does not save the thread") {
                        testGroupThread.mockData[.uniqueId] = nil
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(testGroupThread.numSaveCalls).to(equal(0))
                    }
                }
                
                context("when not given a public key") {
                    it("saves the open group with the existing public key") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: nil,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockStorage)
                            .to(call(matchingParameters: true) {
                                $0.setOpenGroup(
                                    OpenGroup(
                                        server: "testServer",
                                        room: "testRoom",
                                        publicKey: TestConstants.publicKey,
                                        name: "test",
                                        groupDescription: nil,
                                        imageID: nil,
                                        infoUpdates: 10
                                    ),
                                    for: "TestGroupId",
                                    using: testTransaction! as Any
                                )
                            })
                    }
                }
                
                context("when it cannot get the public key") {
                    it("does not save the thread") {
                        mockStorage.when { $0.getOpenGroup(for: any()) }.thenReturn(nil)
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: nil,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(testGroupThread.numSaveCalls).to(equal(0))
                    }
                }
                
                context("when storing the open group") {
                    it("defaults the infoUpdates to zero") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        mockStorage.when { $0.getOpenGroup(for: any()) }.thenReturn(nil)
                        testPollInfo = OpenGroupAPI.RoomPollInfo(
                            token: "testRoom",
                            activeUsers: 10,
                            admin: false,
                            globalAdmin: false,
                            moderator: false,
                            globalModerator: false,
                            read: false,
                            defaultRead: nil,
                            defaultAccessible: nil,
                            write: false,
                            defaultWrite: nil,
                            upload: false,
                            defaultUpload: nil,
                            details: nil
                        )
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockStorage)
                            .to(call(matchingParameters: true) {
                                $0.setOpenGroup(
                                    OpenGroup(
                                        server: "testServer",
                                        room: "testRoom",
                                        publicKey: TestConstants.publicKey,
                                        name: "TestTitle",
                                        groupDescription: nil,
                                        imageID: nil,
                                        infoUpdates: 0
                                    ),
                                    for: "TestGroupId",
                                    using: testTransaction! as Any
                                )
                            })
                    }
                }
                
                context("when checking to start polling") {
                    it("starts a new poller when not already polling") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        mockOGMCache.when { $0.pollers }.thenReturn([:])
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockOGMCache)
                            .to(call(matchingParameters: true) {
                                $0.pollers = ["testServer": OpenGroupAPI.Poller(for: "testServer")]
                            })
                    }
                    
                    it("does not start a new poller when already polling") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        mockOGMCache.when { $0.pollers }.thenReturn(["testServer": OpenGroupAPI.Poller(for: "testServer")])
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockOGMCache).to(call(.exactly(times: 1)) { $0.pollers })
                    }
                }
                
                context("when trying to get the room image") {
                    beforeEach {
                        let image: UIImage = UIImage(color: .red, size: CGSize(width: 1, height: 1))
                        let imageData: Data = image.pngData()!
                        mockStorage.when { $0.getOpenGroupImage(for: any(), on: any()) }.thenReturn(nil)
                        
                        mockOGMCache.when { $0.groupImagePromises }
                            .thenReturn(["testServer.testRoom": Promise.value(imageData)])
                    }
                    
                    it("uses the provided room image id if available") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        testPollInfo = OpenGroupAPI.RoomPollInfo(
                            token: "testRoom",
                            activeUsers: 10,
                            admin: false,
                            globalAdmin: false,
                            moderator: false,
                            globalModerator: false,
                            read: false,
                            defaultRead: nil,
                            defaultAccessible: nil,
                            write: false,
                            defaultWrite: nil,
                            upload: false,
                            defaultUpload: nil,
                            details: OpenGroupAPI.Room(
                                token: "test",
                                name: "test",
                                roomDescription: nil,
                                infoUpdates: 0,
                                messageSequence: 0,
                                created: 0,
                                activeUsers: 0,
                                activeUsersCutoff: 0,
                                imageId: 10,
                                pinnedMessages: nil,
                                admin: false,
                                globalAdmin: false,
                                admins: [],
                                hiddenAdmins: nil,
                                moderator: false,
                                globalModerator: false,
                                moderators: [],
                                hiddenModerators: nil,
                                read: false,
                                defaultRead: nil,
                                defaultAccessible: nil,
                                write: false,
                                defaultWrite: nil,
                                upload: false,
                                defaultUpload: nil
                            )
                        )
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockStorage)
                            .to(call(matchingParameters: true) {
                                $0.setOpenGroup(
                                    OpenGroup(
                                        server: "testServer",
                                        room: "testRoom",
                                        publicKey: TestConstants.publicKey,
                                        name: "test",
                                        groupDescription: nil,
                                        imageID: "10",
                                        infoUpdates: 0
                                    ),
                                    for: "TestGroupId",
                                    using: testTransaction! as Any
                                )
                            })
                        expect(testGroupThread.groupModel.groupImage)
                            .toEventuallyNot(
                                beNil(),
                                timeout: .milliseconds(50)
                            )
                        expect(testGroupThread.numSaveCalls)
                            .toEventually(
                                equal(2),   // Call to save the open group and then to save the image
                                timeout: .milliseconds(50)
                            )
                    }
                    
                    it("uses the existing room image id if none is provided") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        mockStorage
                            .when { $0.getOpenGroup(for: any()) }
                            .thenReturn(
                                OpenGroup(
                                    server: "testServer",
                                    room: "testRoom",
                                    publicKey: TestConstants.publicKey,
                                    name: "Test",
                                    groupDescription: nil,
                                    imageID: "12",
                                    infoUpdates: 10
                                )
                            )
                        testPollInfo = OpenGroupAPI.RoomPollInfo(
                            token: "testRoom",
                            activeUsers: 10,
                            admin: false,
                            globalAdmin: false,
                            moderator: false,
                            globalModerator: false,
                            read: false,
                            defaultRead: nil,
                            defaultAccessible: nil,
                            write: false,
                            defaultWrite: nil,
                            upload: false,
                            defaultUpload: nil,
                            details: nil
                        )
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockStorage)
                            .to(call(matchingParameters: true) {
                                $0.setOpenGroup(
                                    OpenGroup(
                                        server: "testServer",
                                        room: "testRoom",
                                        publicKey: TestConstants.publicKey,
                                        name: "TestTitle",
                                        groupDescription: nil,
                                        imageID: "12",
                                        infoUpdates: 10
                                    ),
                                    for: "TestGroupId",
                                    using: testTransaction! as Any
                                )
                            })
                        expect(testGroupThread.groupModel.groupImage)
                            .toEventuallyNot(
                                beNil(),
                                timeout: .milliseconds(50)
                            )
                        expect(testGroupThread.numSaveCalls)
                            .toEventually(
                                equal(2),   // Call to save the open group and then to save the image
                                timeout: .milliseconds(50)
                            )
                    }
                    
                    it("uses the new room image id if there is an existing one") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        testGroupThread.mockData[.groupModel] = TSGroupModel(
                            title: "TestTitle",
                            memberIds: [],
                            image: UIImage(color: .blue, size: CGSize(width: 1, height: 1)),
                            groupId: LKGroupUtilities.getEncodedOpenGroupIDAsData("testServer.testRoom"),
                            groupType: .openGroup,
                            adminIds: [],
                            moderatorIds: []
                        )
                        mockStorage
                            .when { $0.getOpenGroup(for: any()) }
                            .thenReturn(
                                OpenGroup(
                                    server: "testServer",
                                    room: "testRoom",
                                    publicKey: TestConstants.publicKey,
                                    name: "Test",
                                    groupDescription: nil,
                                    imageID: "12",
                                    infoUpdates: 10
                                )
                            )
                        testPollInfo = OpenGroupAPI.RoomPollInfo(
                            token: "testRoom",
                            activeUsers: 10,
                            admin: false,
                            globalAdmin: false,
                            moderator: false,
                            globalModerator: false,
                            read: false,
                            defaultRead: nil,
                            defaultAccessible: nil,
                            write: false,
                            defaultWrite: nil,
                            upload: false,
                            defaultUpload: nil,
                            details: OpenGroupAPI.Room(
                                token: "test",
                                name: "test",
                                roomDescription: nil,
                                infoUpdates: 10,
                                messageSequence: 0,
                                created: 0,
                                activeUsers: 0,
                                activeUsersCutoff: 0,
                                imageId: 10,
                                pinnedMessages: nil,
                                admin: false,
                                globalAdmin: false,
                                admins: [],
                                hiddenAdmins: nil,
                                moderator: false,
                                globalModerator: false,
                                moderators: [],
                                hiddenModerators: nil,
                                read: false,
                                defaultRead: nil,
                                defaultAccessible: nil,
                                write: false,
                                defaultWrite: nil,
                                upload: false,
                                defaultUpload: nil
                            )
                        )
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockStorage)
                            .toEventually(call(matchingParameters: true) {
                                $0.setOpenGroup(
                                    OpenGroup(
                                        server: "testServer",
                                        room: "testRoom",
                                        publicKey: TestConstants.publicKey,
                                        name: "test",
                                        groupDescription: nil,
                                        imageID: "10",
                                        infoUpdates: 10
                                    ),
                                    for: "TestGroupId",
                                    using: testTransaction! as Any
                                )
                            })
                        expect(testGroupThread.groupModel.groupImage)
                            .toEventuallyNot(
                                beNil(),
                                timeout: .milliseconds(50)
                            )
                        expect(mockOGMCache)
                            .toEventually(
                                call(.exactly(times: 1)) { $0.groupImagePromises },
                                timeout: .milliseconds(50)
                            )
                        expect(testGroupThread.numSaveCalls)
                            .toEventually(
                                equal(2),   // Call to save the open group and then to save the image
                                timeout: .milliseconds(50)
                            )
                    }
                    
                    it("does nothing if there is no room image") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(testGroupThread.groupModel.groupImage)
                            .toEventually(
                                beNil(),
                                timeout: .milliseconds(50)
                            )
                        expect(testGroupThread.numSaveCalls)
                            .toEventually(
                                equal(1),
                                timeout: .milliseconds(50)
                            )
                    }
                    
                    it("does nothing if it fails to retrieve the room image") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        mockOGMCache.when { $0.groupImagePromises }
                            .thenReturn(["testServer.testRoom": Promise(error: HTTP.Error.generic)])
                        
                        testPollInfo = OpenGroupAPI.RoomPollInfo(
                            token: "testRoom",
                            activeUsers: 10,
                            admin: false,
                            globalAdmin: false,
                            moderator: false,
                            globalModerator: false,
                            read: false,
                            defaultRead: nil,
                            defaultAccessible: nil,
                            write: false,
                            defaultWrite: nil,
                            upload: false,
                            defaultUpload: nil,
                            details: OpenGroupAPI.Room(
                                token: "test",
                                name: "test",
                                roomDescription: nil,
                                infoUpdates: 0,
                                messageSequence: 0,
                                created: 0,
                                activeUsers: 0,
                                activeUsersCutoff: 0,
                                imageId: 10,
                                pinnedMessages: nil,
                                admin: false,
                                globalAdmin: false,
                                admins: [],
                                hiddenAdmins: nil,
                                moderator: false,
                                globalModerator: false,
                                moderators: [],
                                hiddenModerators: nil,
                                read: false,
                                defaultRead: nil,
                                defaultAccessible: nil,
                                write: false,
                                defaultWrite: nil,
                                upload: false,
                                defaultUpload: nil
                            )
                        )
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(testGroupThread.groupModel.groupImage)
                            .toEventually(
                                beNil(),
                                timeout: .milliseconds(50)
                            )
                        expect(testGroupThread.numSaveCalls)
                            .toEventually(
                                equal(1),
                                timeout: .milliseconds(50)
                            )
                    }
                    
                    it("saves the retrieved room image") {
                        var didComplete: Bool = false   // Prevent multi-threading test bugs
                        
                        testPollInfo = OpenGroupAPI.RoomPollInfo(
                            token: "testRoom",
                            activeUsers: 10,
                            admin: false,
                            globalAdmin: false,
                            moderator: false,
                            globalModerator: false,
                            read: false,
                            defaultRead: nil,
                            defaultAccessible: nil,
                            write: false,
                            defaultWrite: nil,
                            upload: false,
                            defaultUpload: nil,
                            details: OpenGroupAPI.Room(
                                token: "test",
                                name: "test",
                                roomDescription: nil,
                                infoUpdates: 10,
                                messageSequence: 0,
                                created: 0,
                                activeUsers: 0,
                                activeUsersCutoff: 0,
                                imageId: 10,
                                pinnedMessages: nil,
                                admin: false,
                                globalAdmin: false,
                                admins: [],
                                hiddenAdmins: nil,
                                moderator: false,
                                globalModerator: false,
                                moderators: [],
                                hiddenModerators: nil,
                                read: false,
                                defaultRead: nil,
                                defaultAccessible: nil,
                                write: false,
                                defaultWrite: nil,
                                upload: false,
                                defaultUpload: nil
                            )
                        )
                        
                        OpenGroupManager.handlePollInfo(
                            testPollInfo,
                            publicKey: TestConstants.publicKey,
                            for: "testRoom",
                            on: "testServer",
                            using: testTransaction,
                            dependencies: dependencies
                        ) { didComplete = true }
                        
                        expect(didComplete).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(testGroupThread.groupModel.groupImage)
                            .toEventuallyNot(
                                beNil(),
                                timeout: .milliseconds(50)
                            )
                        expect(testGroupThread.numSaveCalls)
                            .toEventually(
                                equal(2),   // Call to save the open group and then to save the image
                                timeout: .milliseconds(50)
                            )
                    }
                }
            }
            
            // MARK: - --handleMessages
            
            context("when handling messages") {
                beforeEach {
                    testTransaction.mockData[.objectForKey] = [
                        "TestGroupId": testGroupThread,
                        "TestMessageId": testIncomingMessage
                    ]
                    
                    mockStorage
                        .when {
                            $0.setOpenGroupSequenceNumber(
                                for: any(),
                                on: any(),
                                to: any(),
                                using: testTransaction as Any
                            )
                        }
                        .thenReturn(())
                    mockStorage.when { $0.getUserPublicKey() }.thenReturn("05\(TestConstants.publicKey)")
                    mockStorage.when { $0.getReceivedMessageTimestamps(using: testTransaction as Any) }.thenReturn([])
                    mockStorage.when { $0.addReceivedMessageTimestamp(any(), using: testTransaction as Any) }.thenReturn(())
                    mockStorage.when { $0.persist(anyArray(), using: testTransaction as Any) }.thenReturn([])
                    mockStorage
                        .when {
                            $0.getOrCreateThread(
                                for: any(),
                                groupPublicKey: any(),
                                openGroupID: any(),
                                using: testTransaction as Any
                            )
                        }
                        .thenReturn("TestGroupId")
                    mockStorage
                        .when {
                            $0.persist(
                                any(),
                                quotedMessage: nil,
                                linkPreview: nil,
                                groupPublicKey: any(),
                                openGroupID: any(),
                                using: testTransaction as Any
                            )
                        }
                        .thenReturn("TestMessageId")
                    mockStorage.when { $0.getContact(with: any()) }.thenReturn(nil)
                }
                
                it("updates the sequence number when there are messages") {
                    OpenGroupManager.handleMessages(
                        [
                            OpenGroupAPI.Message(
                                id: 1,
                                sender: nil,
                                posted: 123,
                                edited: nil,
                                seqNo: 124,
                                whisper: false,
                                whisperMods: false,
                                whisperTo: nil,
                                base64EncodedData: nil,
                                base64EncodedSignature: nil
                            )
                        ],
                        for: "testRoom",
                        on: "testServer",
                        isBackgroundPoll: false,
                        using: testTransaction,
                        dependencies: dependencies
                    )
                    
                    expect(mockStorage)
                        .to(call(matchingParameters: true) {
                            $0.setOpenGroupSequenceNumber(
                                for: "testRoom",
                                on: "testServer",
                                to: 124,
                                using: testTransaction! as Any
                            )
                        })
                }
                
                it("does not update the sequence number if there are no messages") {
                    OpenGroupManager.handleMessages(
                        [],
                        for: "testRoom",
                        on: "testServer",
                        isBackgroundPoll: false,
                        using: testTransaction,
                        dependencies: dependencies
                    )
                    
                    expect(mockStorage)
                        .toNot(call {
                            $0.setOpenGroupSequenceNumber(for: any(), on: any(), to: any(), using: testTransaction as Any)
                        })
                }
                
                it("ignores a message with no sender") {
                    OpenGroupManager.handleMessages(
                        [
                            OpenGroupAPI.Message(
                                id: 1,
                                sender: nil,
                                posted: 123,
                                edited: nil,
                                seqNo: 124,
                                whisper: false,
                                whisperMods: false,
                                whisperTo: nil,
                                base64EncodedData: Data([1, 2, 3]).base64EncodedString(),
                                base64EncodedSignature: nil
                            )
                        ],
                        for: "testRoom",
                        on: "testServer",
                        isBackgroundPoll: false,
                        using: testTransaction,
                        dependencies: dependencies
                    )
                    
                    expect(testIncomingMessage.didCallSave).toEventuallyNot(beTrue(), timeout: .milliseconds(50))
                    expect(testIncomingMessage.didCallRemove).toEventuallyNot(beTrue(), timeout: .milliseconds(50))
                }
                
                it("ignores a message with invalid data") {
                    OpenGroupManager.handleMessages(
                        [
                            OpenGroupAPI.Message(
                                id: 1,
                                sender: "05\(TestConstants.publicKey)",
                                posted: 123,
                                edited: nil,
                                seqNo: 124,
                                whisper: false,
                                whisperMods: false,
                                whisperTo: nil,
                                base64EncodedData: Data([1, 2, 3]).base64EncodedString(),
                                base64EncodedSignature: nil
                            )
                        ],
                        for: "testRoom",
                        on: "testServer",
                        isBackgroundPoll: false,
                        using: testTransaction,
                        dependencies: dependencies
                    )
                    
                    expect(testIncomingMessage.didCallSave).toEventuallyNot(beTrue(), timeout: .milliseconds(50))
                    expect(testIncomingMessage.didCallRemove).toEventuallyNot(beTrue(), timeout: .milliseconds(50))
                }
                
                it("processes a message with valid data") {
                    OpenGroupManager.handleMessages(
                        [testMessage],
                        for: "testRoom",
                        on: "testServer",
                        isBackgroundPoll: false,
                        using: testTransaction,
                        dependencies: dependencies
                    )
                    
                    expect(testIncomingMessage.didCallSave)
                        .toEventually(
                            beTrue(),
                            timeout: .milliseconds(50)
                        )
                }
                
                it("processes valid messages when combined with invalid ones") {
                    OpenGroupManager.handleMessages(
                        [
                            OpenGroupAPI.Message(
                                id: 2,
                                sender: "05\(TestConstants.publicKey)",
                                posted: 122,
                                edited: nil,
                                seqNo: 123,
                                whisper: false,
                                whisperMods: false,
                                whisperTo: nil,
                                base64EncodedData: Data([1, 2, 3]).base64EncodedString(),
                                base64EncodedSignature: nil
                            ),
                            testMessage,
                        ],
                        for: "testRoom",
                        on: "testServer",
                        isBackgroundPoll: false,
                        using: testTransaction,
                        dependencies: dependencies
                    )
                    
                    expect(testIncomingMessage.didCallSave)
                        .toEventually(
                            beTrue(),
                            timeout: .milliseconds(50)
                        )
                }
                
                context("with no data") {
                    it("deletes the message if we have the message") {
                        testTransaction.mockData[.objectForKey] = testGroupThread
                        
                        OpenGroupManager.handleMessages(
                            [
                                OpenGroupAPI.Message(
                                    id: 127,
                                    sender: "05\(TestConstants.publicKey)",
                                    posted: 123,
                                    edited: nil,
                                    seqNo: 123,
                                    whisper: false,
                                    whisperMods: false,
                                    whisperTo: nil,
                                    base64EncodedData: nil,
                                    base64EncodedSignature: nil
                                )
                            ],
                            for: "testRoom",
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(testIncomingMessage.didCallRemove)
                            .toEventually(
                                beTrue(),
                                timeout: .milliseconds(50)
                            )
                    }
                    
                    it("does nothing if we do not have the thread") {
                        testTransaction.mockData[.objectForKey] = nil
                        
                        OpenGroupManager.handleMessages(
                            [
                                OpenGroupAPI.Message(
                                    id: 1,
                                    sender: "05\(TestConstants.publicKey)",
                                    posted: 123,
                                    edited: nil,
                                    seqNo: 123,
                                    whisper: false,
                                    whisperMods: false,
                                    whisperTo: nil,
                                    base64EncodedData: nil,
                                    base64EncodedSignature: nil
                                )
                            ],
                            for: "testRoom",
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(testIncomingMessage.didCallRemove)
                            .toEventuallyNot(
                                beTrue(),
                                timeout: .milliseconds(50)
                            )
                    }
                    
                    it("does nothing if we do not have the message") {
                        testGroupThread.mockData[.interactions] = [testInteraction]
                        testTransaction.mockData[.objectForKey] = testGroupThread
                        
                        OpenGroupManager.handleMessages(
                            [
                                OpenGroupAPI.Message(
                                    id: 127,
                                    sender: "05\(TestConstants.publicKey)",
                                    posted: 123,
                                    edited: nil,
                                    seqNo: 123,
                                    whisper: false,
                                    whisperMods: false,
                                    whisperTo: nil,
                                    base64EncodedData: nil,
                                    base64EncodedSignature: nil
                                )
                            ],
                            for: "testRoom",
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(testIncomingMessage.didCallRemove)
                            .toEventuallyNot(
                                beTrue(),
                                timeout: .milliseconds(50)
                            )
                    }
                }
            }
            
            // MARK: - --handleDirectMessages
            
            context("when handling direct messages") {
                beforeEach {
                    testTransaction.mockData[.objectForKey] = testContactThread
                    
                    mockStorage
                        .when { $0.setOpenGroupInboxLatestMessageId(for: any(), to: any(), using: testTransaction as Any) }
                        .thenReturn(())
                    
                    mockStorage
                        .when { $0.setOpenGroupOutboxLatestMessageId(for: any(), to: any(), using: testTransaction as Any) }
                        .thenReturn(())
                    mockStorage.when { $0.getUserPublicKey() }.thenReturn("05\(TestConstants.publicKey)")
                    mockStorage.when { $0.getReceivedMessageTimestamps(using: testTransaction as Any) }.thenReturn([])
                    mockStorage.when { $0.addReceivedMessageTimestamp(any(), using: testTransaction as Any) }.thenReturn(())
                    mockSodium
                        .when {
                            $0.sharedBlindedEncryptionKey(
                                secretKey: anyArray(),
                                otherBlindedPublicKey: anyArray(),
                                fromBlindedPublicKey: anyArray(),
                                toBlindedPublicKey: anyArray(),
                                genericHash: mockGenericHash
                            )
                        }
                        .thenReturn([])
                    mockSodium
                        .when { $0.generateBlindingFactor(serverPublicKey: any(), genericHash: mockGenericHash) }
                        .thenReturn([])
                    mockAeadXChaCha20Poly1305Ietf
                        .when {
                            $0.decrypt(
                                authenticatedCipherText: anyArray(),
                                secretKey: anyArray(),
                                nonce: anyArray()
                            )
                        }
                        .thenReturn(
                            Data(base64Encoded:"ChQKC1Rlc3RNZXNzYWdlONCI7I/3Iw==")!.bytes +
                            [UInt8](repeating: 0, count: 32)
                        )
                    mockSign
                        .when { $0.toX25519(ed25519PublicKey: anyArray()) }
                        .thenReturn(Data(hex: TestConstants.publicKey).bytes)
                    mockStorage.when { $0.persist(anyArray(), using: testTransaction as Any) }.thenReturn([])
                    mockStorage
                        .when {
                            $0.getOrCreateThread(
                                for: any(),
                                groupPublicKey: any(),
                                openGroupID: any(),
                                using: testTransaction as Any
                            )
                        }
                        .thenReturn("TestContactId")
                    mockStorage
                        .when {
                            $0.persist(
                                any(),
                                quotedMessage: nil,
                                linkPreview: nil,
                                groupPublicKey: any(),
                                openGroupID: any(),
                                using: testTransaction as Any
                            )
                        }
                        .thenReturn("TestMessageId")
                    mockStorage.when { $0.getContact(with: any()) }.thenReturn(nil)
                    mockStorage
                        .when { $0.getBlindedIdMapping(with: any(), using: testTransaction) }
                        .thenReturn(nil)
                    mockStorage
                        .when { $0.enumerateBlindedIdMapping(using: testTransaction, with: { _, _ in }) }
                        .then { args in
                            guard let block = args.first as? (BlindedIdMapping, UnsafeMutablePointer<ObjCBool>) -> () else {
                                return
                            }
                            
                            var stop: ObjCBool = false
                            block(any(), &stop)
                        }
                        .thenReturn(())
                }
                
                it("does nothing if there are no messages") {
                    OpenGroupManager.handleDirectMessages(
                        [],
                        fromOutbox: false,
                        on: "testServer",
                        isBackgroundPoll: false,
                        using: testTransaction,
                        dependencies: dependencies
                    )
                    
                    expect(testContactThread.numSaveCalls).to(equal(0))
                    expect(mockStorage)
                        .toNot(call {
                            $0.setOpenGroupInboxLatestMessageId(
                                for: any(),
                                to: any(),
                                using: testTransaction! as Any
                            )
                        })
                    expect(mockStorage)
                        .toNot(call {
                            $0.setOpenGroupOutboxLatestMessageId(
                                for: any(),
                                to: any(),
                                using: testTransaction! as Any
                            )
                        })
                }
                
                it("does nothing if it cannot get the open group public key") {
                    mockStorage
                        .when { $0.getOpenGroupPublicKey(for: any()) }
                        .thenReturn(nil)
                    
                    OpenGroupManager.handleDirectMessages(
                        [testDirectMessage],
                        fromOutbox: false,
                        on: "testServer",
                        isBackgroundPoll: false,
                        using: testTransaction,
                        dependencies: dependencies
                    )
                    
                    expect(testContactThread.numSaveCalls).to(equal(0))
                    expect(mockStorage)
                        .toNot(call {
                            $0.setOpenGroupInboxLatestMessageId(
                                for: any(),
                                to: any(),
                                using: testTransaction! as Any
                            )
                        })
                    expect(mockStorage)
                        .toNot(call {
                            $0.setOpenGroupOutboxLatestMessageId(
                                for: any(),
                                to: any(),
                                using: testTransaction! as Any
                            )
                        })
                }
                
                it("ignores messages with non base64 encoded data") {
                    testDirectMessage = OpenGroupAPI.DirectMessage(
                        id: testDirectMessage.id,
                        sender: testDirectMessage.sender,
                        recipient: testDirectMessage.recipient,
                        posted: testDirectMessage.posted,
                        expires: testDirectMessage.expires,
                        base64EncodedMessage: "TestMessage%%%"
                    )
                    
                    OpenGroupManager.handleDirectMessages(
                        [testDirectMessage],
                        fromOutbox: false,
                        on: "testServer",
                        isBackgroundPoll: false,
                        using: testTransaction,
                        dependencies: dependencies
                    )
                    
                    expect(testContactThread.numSaveCalls).to(equal(0))
                }
                
                context("for the inbox") {
                    beforeEach {
                        mockSodium
                            .when { $0.combineKeys(lhsKeyBytes: anyArray(), rhsKeyBytes: anyArray()) }
                            .thenReturn(Data(hex: testDirectMessage.sender.removingIdPrefixIfNeeded()).bytes)
                    }
                    
                    it("updates the inbox latest message id") {
                        OpenGroupManager.handleDirectMessages(
                            [testDirectMessage],
                            fromOutbox: false,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(mockStorage)
                            .to(call(matchingParameters: true) {
                                $0.setOpenGroupInboxLatestMessageId(
                                    for: "testServer",
                                    to: 128,
                                    using: testTransaction! as Any
                                )
                            })
                    }
                    
                    it("ignores a message with invalid data") {
                        testDirectMessage = OpenGroupAPI.DirectMessage(
                            id: testDirectMessage.id,
                            sender: testDirectMessage.sender,
                            recipient: testDirectMessage.recipient,
                            posted: testDirectMessage.posted,
                            expires: testDirectMessage.expires,
                            base64EncodedMessage: Data([1, 2, 3]).base64EncodedString()
                        )
                        
                        OpenGroupManager.handleDirectMessages(
                            [testDirectMessage],
                            fromOutbox: false,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(testContactThread.numSaveCalls).to(equal(0))
                    }
                    
                    it("processes a message with valid data") {
                        OpenGroupManager.handleDirectMessages(
                            [testDirectMessage],
                            fromOutbox: false,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        // Saved once per valid inbox message
                        expect(testContactThread.numSaveCalls).to(equal(1))
                    }
                    
                    it("processes valid messages when combined with invalid ones") {
                        OpenGroupManager.handleDirectMessages(
                            [
                                OpenGroupAPI.DirectMessage(
                                    id: testDirectMessage.id,
                                    sender: testDirectMessage.sender,
                                    recipient: testDirectMessage.recipient,
                                    posted: testDirectMessage.posted,
                                    expires: testDirectMessage.expires,
                                    base64EncodedMessage: Data([1, 2, 3]).base64EncodedString()
                                ),
                                testDirectMessage
                            ],
                            fromOutbox: false,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        // Saved once per valid inbox message
                        expect(testContactThread.numSaveCalls).to(equal(1))
                    }
                }
                
                context("for the outbox") {
                    beforeEach {
                        mockSodium
                            .when { $0.combineKeys(lhsKeyBytes: anyArray(), rhsKeyBytes: anyArray()) }
                            .thenReturn(Data(hex: testDirectMessage.recipient.removingIdPrefixIfNeeded()).bytes)
                    }
                    
                    it("updates the outbox latest message id") {
                        OpenGroupManager.handleDirectMessages(
                            [testDirectMessage],
                            fromOutbox: true,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(mockStorage)
                            .to(call {
                                $0.setOpenGroupOutboxLatestMessageId(
                                    for: "testServer",
                                    to: 128,
                                    using: testTransaction! as Any
                                )
                            })
                    }
                    
                    it("retrieves an existing blinded id mapping") {
                        mockStorage
                            .when { $0.getBlindedIdMapping(with: any(), using: testTransaction) }
                            .thenReturn(
                                BlindedIdMapping(
                                    blindedId: "15\(TestConstants.publicKey)",
                                    sessionId: "TestSessionId",
                                    serverPublicKey: "05\(TestConstants.publicKey)"
                                )
                            )
                        
                        OpenGroupManager.handleDirectMessages(
                            [testDirectMessage],
                            fromOutbox: true,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(mockStorage)
                            .to(call(.exactly(times: 1)) {
                                $0.getBlindedIdMapping(with: any(), using: testTransaction)
                            })
                        expect(mockStorage)
                            .to(call(matchingParameters: true) {
                                $0.getOrCreateThread(
                                    for: "TestSessionId",
                                    groupPublicKey: nil,
                                    openGroupID: nil,
                                    using: testTransaction! as Any
                                )
                            })
                        
                        // Saved twice per valid outbox message
                        expect(testContactThread.numSaveCalls).to(equal(2))
                    }
                    
                    it("locally caches blinded id mappings for the same recipient") {
                        mockStorage
                            .when { $0.getBlindedIdMapping(with: any(), using: testTransaction) }
                            .thenReturn(
                                BlindedIdMapping(
                                    blindedId: "15\(TestConstants.publicKey)",
                                    sessionId: "TestSessionId",
                                    serverPublicKey: "05\(TestConstants.publicKey)"
                                )
                            )
                        
                        OpenGroupManager.handleDirectMessages(
                            [
                                testDirectMessage,
                                OpenGroupAPI.DirectMessage(
                                    id: testDirectMessage.id + 1,
                                    sender: testDirectMessage.sender,
                                    recipient: testDirectMessage.recipient,
                                    posted: testDirectMessage.posted + 1,
                                    expires: testDirectMessage.expires + 1,
                                    base64EncodedMessage: testDirectMessage.base64EncodedMessage
                                )
                            ],
                            fromOutbox: true,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(mockStorage)
                            .to(call(.exactly(times: 1)) {
                                $0.getBlindedIdMapping(with: any(), using: testTransaction)
                            })
                        
                        // Saved twice per valid outbox message
                        expect(testContactThread.numSaveCalls).to(equal(4))
                    }
                    
                    it("falls back to using the blinded id if no mapping is found") {
                        OpenGroupManager.handleDirectMessages(
                            [testDirectMessage],
                            fromOutbox: true,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(mockStorage)
                            .to(call(.exactly(times: 1)) {
                                $0.getBlindedIdMapping(with: any(), using: testTransaction)
                            })
                        expect(mockStorage)
                            .to(call(matchingParameters: true) {
                                $0.getOrCreateThread(
                                    for: "15\(TestConstants.publicKey)",
                                    groupPublicKey: nil,
                                    openGroupID: nil,
                                    using: testTransaction! as Any
                                )
                            })
                        
                        // Saved twice per valid outbox message
                        expect(testContactThread.numSaveCalls).to(equal(2))
                    }
                    
                    it("ignores a message with invalid data") {
                        testDirectMessage = OpenGroupAPI.DirectMessage(
                            id: testDirectMessage.id,
                            sender: testDirectMessage.sender,
                            recipient: testDirectMessage.recipient,
                            posted: testDirectMessage.posted,
                            expires: testDirectMessage.expires,
                            base64EncodedMessage: Data([1, 2, 3]).base64EncodedString()
                        )
                        
                        OpenGroupManager.handleDirectMessages(
                            [testDirectMessage],
                            fromOutbox: true,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(testContactThread.numSaveCalls).to(equal(0))
                    }
                    
                    it("processes a message with valid data") {
                        OpenGroupManager.handleDirectMessages(
                            [testDirectMessage],
                            fromOutbox: true,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        // Saved twice per valid outbox message
                        expect(testContactThread.numSaveCalls).to(equal(2))
                    }
                    
                    it("processes valid messages when combined with invalid ones") {
                        OpenGroupManager.handleDirectMessages(
                            [
                                OpenGroupAPI.DirectMessage(
                                    id: testDirectMessage.id,
                                    sender: testDirectMessage.sender,
                                    recipient: testDirectMessage.recipient,
                                    posted: testDirectMessage.posted,
                                    expires: testDirectMessage.expires,
                                    base64EncodedMessage: Data([1, 2, 3]).base64EncodedString()
                                ),
                                testDirectMessage
                            ],
                            fromOutbox: true,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        // Saved twice per valid outbox message
                        expect(testContactThread.numSaveCalls).to(equal(2))
                    }
                    
                    it("updates the contact thread with the open group information") {
                        expect(testContactThread.originalOpenGroupServer).to(beNil())
                        expect(testContactThread.originalOpenGroupPublicKey).to(beNil())
                        
                        OpenGroupManager.handleDirectMessages(
                            [testDirectMessage],
                            fromOutbox: true,
                            on: "testServer",
                            isBackgroundPoll: false,
                            using: testTransaction,
                            dependencies: dependencies
                        )
                        
                        expect(testContactThread.originalOpenGroupServer).to(equal("testServer"))
                        expect(testContactThread.originalOpenGroupPublicKey).to(equal(TestConstants.publicKey))
                    }
                }
            }
            
            // MARK: - Convenience
            
            // MARK: - --isUserModeratorOrAdmin
            
            context("when determining if a user is a moderator or an admin") {
                beforeEach {
                    mockOGMCache.when { $0.moderators }.thenReturn([:])
                    mockOGMCache.when { $0.admins }.thenReturn([:])
                }
                
                it("uses an empty set for moderators by default") {
                    expect(
                        OpenGroupManager.isUserModeratorOrAdmin(
                            "05\(TestConstants.publicKey)",
                            for: "testRoom",
                            on: "testServer",
                            using: dependencies
                        )
                    ).to(beFalse())
                }
                
                it("uses an empty set for admins by default") {
                    expect(
                        OpenGroupManager.isUserModeratorOrAdmin(
                            "05\(TestConstants.publicKey)",
                            for: "testRoom",
                            on: "testServer",
                            using: dependencies
                        )
                    ).to(beFalse())
                }
                
                it("returns true if the key is in the moderator set") {
                    mockOGMCache.when { $0.moderators }
                        .thenReturn([
                            "testServer": [
                                "testRoom": Set(arrayLiteral: "05\(TestConstants.publicKey)")
                            ]
                        ])
                    
                    expect(
                        OpenGroupManager.isUserModeratorOrAdmin(
                            "05\(TestConstants.publicKey)",
                            for: "testRoom",
                            on: "testServer",
                            using: dependencies
                        )
                    ).to(beTrue())
                }
                
                it("returns true if the key is in the admin set") {
                    mockOGMCache.when { $0.admins }
                        .thenReturn([
                            "testServer": [
                                "testRoom": Set(arrayLiteral: "05\(TestConstants.publicKey)")
                            ]
                        ])
                    
                    expect(
                        OpenGroupManager.isUserModeratorOrAdmin(
                            "05\(TestConstants.publicKey)",
                            for: "testRoom",
                            on: "testServer",
                            using: dependencies
                        )
                    ).to(beTrue())
                }
                
                it("returns false if the key is not a valid session id") {
                    expect(
                        OpenGroupManager.isUserModeratorOrAdmin(
                            "InvalidValue",
                            for: "testRoom",
                            on: "testServer",
                            using: dependencies
                        )
                    ).to(beFalse())
                }
                
                context("and the key is a standard session id") {
                    it("returns false if the key is not the users session id") {
                        let otherKey: String = TestConstants.publicKey.replacingOccurrences(of: "7", with: "6")
                        mockIdentityManager
                            .when { $0.identityKeyPair() }
                            .thenReturn(
                                try! ECKeyPair(
                                    publicKeyData: Data.data(fromHex: otherKey)!,
                                    privateKeyData: Data.data(fromHex: TestConstants.privateKey)!
                                )
                            )
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "05\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beFalse())
                    }
                    
                    it("returns true if the key is the current users and the users unblinded id is a moderator or admin") {
                        let otherKey: String = TestConstants.publicKey.replacingOccurrences(of: "7", with: "6")
                        mockOGMCache.when { $0.moderators }
                            .thenReturn([
                                "testServer": [
                                    "testRoom": Set(arrayLiteral: "00\(otherKey)")
                                ]
                            ])
                        mockStorage
                            .when { $0.getUserED25519KeyPair() }
                            .thenReturn(
                                Box.KeyPair(
                                    publicKey: Data.data(fromHex: otherKey)!.bytes,
                                    secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                                )
                            )
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "05\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beTrue())
                    }
                    
                    it("returns true if the key is the current users and the users blinded id is a moderator or admin") {
                        let otherKey: String = TestConstants.publicKey.replacingOccurrences(of: "7", with: "6")
                        mockOGMCache.when { $0.moderators }
                            .thenReturn([
                                "testServer": [
                                    "testRoom": Set(arrayLiteral: "15\(otherKey)")
                                ]
                            ])
                        mockSodium
                            .when {
                                $0.blindedKeyPair(
                                    serverPublicKey: any(),
                                    edKeyPair: any(),
                                    genericHash: mockGenericHash
                                )
                            }
                            .thenReturn(
                                Box.KeyPair(
                                    publicKey: Data.data(fromHex: otherKey)!.bytes,
                                    secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                                )
                            )
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "05\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beTrue())
                    }
                }
                
                context("and the key is unblinded") {
                    it("returns false if unable to retrieve the user ed25519 key") {
                        mockStorage
                            .when { $0.getUserED25519KeyPair() }
                            .thenReturn(nil)
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "00\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beFalse())
                    }
                    
                    it("returns false if the key is not the users unblinded id") {
                        let otherKey: String = TestConstants.publicKey.replacingOccurrences(of: "7", with: "6")
                        mockStorage
                            .when { $0.getUserED25519KeyPair() }
                            .thenReturn(
                                Box.KeyPair(
                                    publicKey: Data.data(fromHex: otherKey)!.bytes,
                                    secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                                )
                            )
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "00\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beFalse())
                    }
                    
                    it("returns true if the key is the current users and the users session id is a moderator or admin") {
                        let otherKey: String = TestConstants.publicKey.replacingOccurrences(of: "7", with: "6")
                        mockOGMCache.when { $0.moderators }
                            .thenReturn([
                                "testServer": [
                                    "testRoom": Set(arrayLiteral: "05\(otherKey)")
                                ]
                            ])
                        mockIdentityManager
                            .when { $0.identityKeyPair() }
                            .thenReturn(
                                try! ECKeyPair(
                                    publicKeyData: Data.data(fromHex: otherKey)!,
                                    privateKeyData: Data.data(fromHex: TestConstants.privateKey)!
                                )
                            )
                        mockStorage
                            .when { $0.getUserED25519KeyPair() }
                            .thenReturn(
                                Box.KeyPair(
                                    publicKey: Data.data(fromHex: TestConstants.publicKey)!.bytes,
                                    secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                                )
                            )
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "00\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beTrue())
                    }
                    
                    it("returns true if the key is the current users and the users blinded id is a moderator or admin") {
                        let otherKey: String = TestConstants.publicKey.replacingOccurrences(of: "7", with: "6")
                        mockOGMCache.when { $0.moderators }
                            .thenReturn([
                                "testServer": [
                                    "testRoom": Set(arrayLiteral: "15\(otherKey)")
                                ]
                            ])
                        mockSodium
                            .when {
                                $0.blindedKeyPair(
                                    serverPublicKey: any(),
                                    edKeyPair: any(),
                                    genericHash: mockGenericHash
                                )
                            }
                            .thenReturn(
                                Box.KeyPair(
                                    publicKey: Data.data(fromHex: otherKey)!.bytes,
                                    secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                                )
                            )
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "00\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beTrue())
                    }
                }
                
                context("and the key is blinded") {
                    it("returns false if unable to retrieve the user ed25519 key") {
                        mockStorage
                            .when { $0.getUserED25519KeyPair() }
                            .thenReturn(nil)
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "15\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beFalse())
                    }
                    
                    it("returns false if unable to retrieve the public key for the open group server") {
                        mockStorage
                            .when { $0.getOpenGroupPublicKey(for: any()) }
                            .thenReturn(nil)
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "15\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beFalse())
                    }
                    
                    it("returns false if unable generate a blinded key") {
                        mockSodium
                            .when {
                                $0.blindedKeyPair(
                                    serverPublicKey: any(),
                                    edKeyPair: any(),
                                    genericHash: mockGenericHash
                                )
                            }
                            .thenReturn(nil)
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "15\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beFalse())
                    }
                    
                    it("returns false if the key is not the users blinded id") {
                        let otherKey: String = TestConstants.publicKey.replacingOccurrences(of: "7", with: "6")
                        mockSodium
                            .when {
                                $0.blindedKeyPair(
                                    serverPublicKey: any(),
                                    edKeyPair: any(),
                                    genericHash: mockGenericHash
                                )
                            }
                            .thenReturn(
                                Box.KeyPair(
                                    publicKey: Data.data(fromHex: otherKey)!.bytes,
                                    secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                                )
                            )
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "15\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beFalse())
                    }
                    
                    it("returns true if the key is the current users and the users session id is a moderator or admin") {
                        let otherKey: String = TestConstants.publicKey.replacingOccurrences(of: "7", with: "6")
                        mockOGMCache.when { $0.moderators }
                            .thenReturn([
                                "testServer": [
                                    "testRoom": Set(arrayLiteral: "05\(otherKey)")
                                ]
                            ])
                        mockIdentityManager
                            .when { $0.identityKeyPair() }
                            .thenReturn(
                                try! ECKeyPair(
                                    publicKeyData: Data.data(fromHex: otherKey)!,
                                    privateKeyData: Data.data(fromHex: TestConstants.privateKey)!
                                )
                            )
                        mockStorage
                            .when { $0.getUserED25519KeyPair() }
                            .thenReturn(
                                Box.KeyPair(
                                    publicKey: Data.data(fromHex: TestConstants.publicKey)!.bytes,
                                    secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                                )
                            )
                        mockSodium
                            .when {
                                $0.blindedKeyPair(
                                    serverPublicKey: any(),
                                    edKeyPair: any(),
                                    genericHash: mockGenericHash
                                )
                            }
                            .thenReturn(
                                Box.KeyPair(
                                    publicKey: Data.data(fromHex: TestConstants.publicKey)!.bytes,
                                    secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                                )
                            )
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "15\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beTrue())
                    }
                    
                    it("returns true if the key is the current users and the users unblinded id is a moderator or admin") {
                        let otherKey: String = TestConstants.publicKey.replacingOccurrences(of: "7", with: "6")
                        mockOGMCache.when { $0.moderators }
                            .thenReturn([
                                "testServer": [
                                    "testRoom": Set(arrayLiteral: "00\(otherKey)")
                                ]
                            ])
                        mockIdentityManager
                            .when { $0.identityKeyPair() }
                            .thenReturn(
                                try! ECKeyPair(
                                    publicKeyData: Data.data(fromHex: TestConstants.publicKey)!,
                                    privateKeyData: Data.data(fromHex: TestConstants.privateKey)!
                                )
                            )
                        mockStorage
                            .when { $0.getUserED25519KeyPair() }
                            .thenReturn(
                                Box.KeyPair(
                                    publicKey: Data.data(fromHex: otherKey)!.bytes,
                                    secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                                )
                            )
                        mockSodium
                            .when {
                                $0.blindedKeyPair(
                                    serverPublicKey: any(),
                                    edKeyPair: any(),
                                    genericHash: mockGenericHash
                                )
                            }
                            .thenReturn(
                                Box.KeyPair(
                                    publicKey: Data.data(fromHex: TestConstants.publicKey)!.bytes,
                                    secretKey: Data.data(fromHex: TestConstants.edSecretKey)!.bytes
                                )
                            )
                        
                        expect(
                            OpenGroupManager.isUserModeratorOrAdmin(
                                "15\(TestConstants.publicKey)",
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                        ).to(beTrue())
                    }
                }
            }
            
            // MARK: - --getDefaultRoomsIfNeeded
            
            context("when getting the default rooms if needed") {
                beforeEach {
                    class TestRoomsApi: TestOnionRequestAPI {
                        static let roomsData: [OpenGroupAPI.Room] = [
                            TestCapabilitiesAndRoomApi.roomData,
                            OpenGroupAPI.Room(
                                token: "test2",
                                name: "test2",
                                roomDescription: nil,
                                infoUpdates: 11,
                                messageSequence: 0,
                                created: 0,
                                activeUsers: 0,
                                activeUsersCutoff: 0,
                                imageId: 12,
                                pinnedMessages: nil,
                                admin: false,
                                globalAdmin: false,
                                admins: [],
                                hiddenAdmins: nil,
                                moderator: false,
                                globalModerator: false,
                                moderators: [],
                                hiddenModerators: nil,
                                read: false,
                                defaultRead: nil,
                                defaultAccessible: nil,
                                write: false,
                                defaultWrite: nil,
                                upload: false,
                                defaultUpload: nil
                            )
                        ]
                        
                        override class var mockResponse: Data? {
                            return try! JSONEncoder().encode(roomsData)
                        }
                    }
                    dependencies = dependencies.with(onionApi: TestRoomsApi.self)
                    
                    mockOGMCache.when { $0.defaultRoomsPromise }.thenReturn(nil)
                    mockOGMCache.when { $0.groupImagePromises }.thenReturn([:])
                    mockStorage
                        .when { $0.setOpenGroupPublicKey(for: any(), to: any(), using: anyAny())}
                        .thenReturn(())
                    mockStorage.when { $0.getOpenGroupImage(for: any(), on: any()) }.thenReturn(nil)
                    mockStorage
                        .when { $0.setOpenGroupImage(to: any(), for: any(), on: any(), using: anyAny()) }
                        .thenReturn(())
                    mockUserDefaults.when { $0.object(forKey: any()) }.thenReturn(nil)
                    mockUserDefaults.when { $0.set(anyAny(), forKey: any()) }.thenReturn(())
                }
                
                it("caches the promise if there is no cached promise") {
                    let promise = OpenGroupManager.getDefaultRoomsIfNeeded(using: dependencies)
                    
                    expect(mockOGMCache)
                        .to(call(matchingParameters: true) {
                            $0.defaultRoomsPromise = promise
                        })
                }
                
                it("returns the cached promise if there is one") {
                    let (promise, _) = Promise<[OpenGroupAPI.Room]>.pending()
                    mockOGMCache.when { $0.defaultRoomsPromise }.thenReturn(promise)
                    
                    expect(OpenGroupManager.getDefaultRoomsIfNeeded(using: dependencies))
                        .to(equal(promise))
                }
                
                it("stores the public key information") {
                    OpenGroupManager.getDefaultRoomsIfNeeded(using: dependencies)

                    expect(mockStorage)
                        .to(call(matchingParameters: true) {
                            $0.setOpenGroupPublicKey(
                                for: "http://116.203.70.33",
                                to: "a03c383cf63c3c4efe67acc52112a6dd734b3a946b9545f488aaa93da7991238",
                                using: testTransaction! as Any
                            )
                        })
                }
                
                it("fetches rooms for the server") {
                    var response: [OpenGroupAPI.Room]?
                    
                    OpenGroupManager.getDefaultRoomsIfNeeded(using: dependencies)
                        .done { response = $0 }
                        .retainUntilComplete()
                    
                    expect(response)
                        .toEventually(
                            equal(
                                [
                                    TestCapabilitiesAndRoomApi.roomData,
                                    OpenGroupAPI.Room(
                                        token: "test2",
                                        name: "test2",
                                        roomDescription: nil,
                                        infoUpdates: 11,
                                        messageSequence: 0,
                                        created: 0,
                                        activeUsers: 0,
                                        activeUsersCutoff: 0,
                                        imageId: 12,
                                        pinnedMessages: nil,
                                        admin: false,
                                        globalAdmin: false,
                                        admins: [],
                                        hiddenAdmins: nil,
                                        moderator: false,
                                        globalModerator: false,
                                        moderators: [],
                                        hiddenModerators: nil,
                                        read: false,
                                        defaultRead: nil,
                                        defaultAccessible: nil,
                                        write: false,
                                        defaultWrite: nil,
                                        upload: false,
                                        defaultUpload: nil
                                    )
                                ]
                            ),
                            timeout: .milliseconds(50)
                        )
                }
                
                it("will retry fetching rooms 8 times before it fails") {
                    class TestRoomsApi: TestOnionRequestAPI {
                        static var callCounter: Int = 0
                        
                        override class var mockResponse: Data? {
                            callCounter += 1
                            return nil
                        }
                    }
                    dependencies = dependencies.with(onionApi: TestRoomsApi.self)
                    
                    var error: Error?
                    
                    OpenGroupManager.getDefaultRoomsIfNeeded(using: dependencies)
                        .catch { error = $0 }
                        .retainUntilComplete()
                    
                    expect(error?.localizedDescription)
                        .toEventually(
                            equal(HTTP.Error.invalidResponse.localizedDescription),
                            timeout: .milliseconds(50)
                        )
                    expect(TestRoomsApi.callCounter).to(equal(9))   // First attempt + 8 retries
                }
                
                it("removes the cache promise if all retries fail") {
                    class TestRoomsApi: TestOnionRequestAPI {
                        override class var mockResponse: Data? { return nil }
                    }
                    dependencies = dependencies.with(onionApi: TestRoomsApi.self)
                    
                    var error: Error?
                    
                    OpenGroupManager.getDefaultRoomsIfNeeded(using: dependencies)
                        .catch { error = $0 }
                        .retainUntilComplete()
                    
                    expect(error?.localizedDescription)
                        .toEventually(
                            equal(HTTP.Error.invalidResponse.localizedDescription),
                            timeout: .milliseconds(50)
                        )
                    expect(mockOGMCache)
                        .to(call(matchingParameters: true) {
                            $0.defaultRoomsPromise = nil
                        })
                }
                
                it("fetches the image for any rooms with images") {
                    class TestRoomsApi: TestOnionRequestAPI {
                        static let roomsData: [OpenGroupAPI.Room] = [
                            OpenGroupAPI.Room(
                                token: "test2",
                                name: "test2",
                                roomDescription: nil,
                                infoUpdates: 11,
                                messageSequence: 0,
                                created: 0,
                                activeUsers: 0,
                                activeUsersCutoff: 0,
                                imageId: 12,
                                pinnedMessages: nil,
                                admin: false,
                                globalAdmin: false,
                                admins: [],
                                hiddenAdmins: nil,
                                moderator: false,
                                globalModerator: false,
                                moderators: [],
                                hiddenModerators: nil,
                                read: false,
                                defaultRead: nil,
                                defaultAccessible: nil,
                                write: false,
                                defaultWrite: nil,
                                upload: false,
                                defaultUpload: nil
                            )
                        ]
                        
                        override class var mockResponse: Data? {
                            return try! JSONEncoder().encode(roomsData)
                        }
                    }
                    dependencies = dependencies.with(onionApi: TestRoomsApi.self)
                    
                    OpenGroupManager.getDefaultRoomsIfNeeded(using: dependencies)

                    expect(mockStorage)
                        .toEventually(
                            call(matchingParameters: true) {
                                $0.setOpenGroupImage(
                                    to: TestRoomsApi.mockResponse!,
                                    for: "test2",
                                    on: "http://116.203.70.33",
                                    using: testTransaction! as Any
                                )
                            },
                            timeout: .milliseconds(50)
                        )
                }
            }
            
            // MARK: - --roomImage
            
            context("when getting a room image") {
                beforeEach {
                    class TestImageApi: TestOnionRequestAPI {
                        override class var mockResponse: Data? { return Data([1, 2, 3]) }
                    }
                    dependencies = dependencies.with(onionApi: TestImageApi.self)
                    
                    mockUserDefaults.when { $0.object(forKey: any()) }.thenReturn(nil)
                    mockUserDefaults.when { $0.set(anyAny(), forKey: any()) }.thenReturn(())
                    mockStorage.when { $0.getOpenGroupImage(for: any(), on: any()) }.thenReturn(nil)
                    mockStorage
                        .when { $0.setOpenGroupImage(to: any(), for: any(), on: any(), using: anyAny()) }
                        .thenReturn(())
                    mockOGMCache.when { $0.groupImagePromises }.thenReturn([:])
                }
                
                it("retrieves the image retrieval promise from the cache if it exists") {
                    let (promise, _) = Promise<Data>.pending()
                    mockOGMCache
                        .when { $0.groupImagePromises }
                        .thenReturn(["testServer.testRoom": promise])
                    
                    expect(
                        OpenGroupManager
                            .roomImage(
                                1,
                                for: "testRoom",
                                on: "testServer",
                                using: dependencies
                            )
                    ).to(equal(promise))
                }
                
                it("does not save the fetched image to storage") {
                    let promise = OpenGroupManager
                        .roomImage(
                            1,
                            for: "testRoom",
                            on: "testServer",
                            using: dependencies
                        )
                    promise.retainUntilComplete()
                    
                    expect(promise.isFulfilled).toEventually(beTrue(), timeout: .milliseconds(50))
                    expect(mockStorage)
                        .toEventuallyNot(
                            call(matchingParameters: true) {
                                $0.setOpenGroupImage(
                                    to: Data([1, 2, 3]),
                                    for: "testRoom",
                                    on: "testServer",
                                    using: testTransaction! as Any
                                )
                            },
                            timeout: .milliseconds(50)
                        )
                }
                
                it("does not update the image update timestamp") {
                    let promise = OpenGroupManager
                        .roomImage(
                            1,
                            for: "testRoom",
                            on: "testServer",
                            using: dependencies
                        )
                    promise.retainUntilComplete()
                    
                    expect(promise.isFulfilled).toEventually(beTrue(), timeout: .milliseconds(50))
                    expect(mockUserDefaults)
                        .toEventuallyNot(
                            call(matchingParameters: true) {
                                $0.set(
                                    dependencies.date,
                                    forKey: SNUserDefaults.Date.lastOpenGroupImageUpdate.rawValue
                                )
                            },
                            timeout: .milliseconds(50)
                        )
                }
                
                it("adds the image retrieval promise to the cache") {
                    class TestNeverReturningApi: OnionRequestAPIType {
                        static func sendOnionRequest(_ request: URLRequest, to server: String, using version: OnionRequestAPI.Version, with x25519PublicKey: String) -> Promise<(OnionRequestResponseInfoType, Data?)> {
                            return Promise<(OnionRequestResponseInfoType, Data?)>.pending().promise
                        }
                        
                        static func sendOnionRequest(to snode: Snode, invoking method: Snode.Method, with parameters: JSON, using version: OnionRequestAPI.Version, associatedWith publicKey: String?) -> Promise<Data> {
                            return Promise.value(Data())
                        }
                    }
                    dependencies = dependencies.with(onionApi: TestNeverReturningApi.self)
                    
                    let promise = OpenGroupManager.roomImage(
                        1,
                        for: "testRoom",
                        on: "testServer",
                        using: dependencies
                    )
                    
                    expect(mockOGMCache)
                        .toEventually(
                            call(matchingParameters: true) {
                                $0.groupImagePromises = ["testServer.testRoom": promise]
                            },
                            timeout: .milliseconds(50)
                        )
                }
                
                context("for the default server") {
                    it("fetches a new image if there is no cached one") {
                        var result: Data?
                        
                        let promise = OpenGroupManager
                            .roomImage(
                                1,
                                for: "testRoom",
                                on: OpenGroupAPI.defaultServer,
                                using: dependencies
                            )
                            .done { result = $0 }
                        promise.retainUntilComplete()
                        
                        expect(promise.isFulfilled).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(result).toEventually(equal(Data([1, 2, 3])), timeout: .milliseconds(50))
                    }
                    
                    it("saves the fetched image to storage") {
                        let promise = OpenGroupManager
                            .roomImage(
                                1,
                                for: "testRoom",
                                on: OpenGroupAPI.defaultServer,
                                using: dependencies
                            )
                        promise.retainUntilComplete()
                        
                        expect(promise.isFulfilled).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockStorage)
                            .toEventually(
                                call(matchingParameters: true) {
                                    $0.setOpenGroupImage(
                                        to: Data([1, 2, 3]),
                                        for: "testRoom",
                                        on: OpenGroupAPI.defaultServer,
                                        using: testTransaction! as Any
                                    )
                                },
                                timeout: .milliseconds(50)
                            )
                    }
                    
                    it("updates the image update timestamp") {
                        let promise = OpenGroupManager
                            .roomImage(
                                1,
                                for: "testRoom",
                                on: OpenGroupAPI.defaultServer,
                                using: dependencies
                            )
                        promise.retainUntilComplete()
                        
                        expect(promise.isFulfilled).toEventually(beTrue(), timeout: .milliseconds(50))
                        expect(mockUserDefaults)
                            .toEventually(
                                call(matchingParameters: true) {
                                    $0.set(
                                        dependencies.date,
                                        forKey: SNUserDefaults.Date.lastOpenGroupImageUpdate.rawValue
                                    )
                                },
                                timeout: .milliseconds(50)
                            )
                    }
                    
                    context("and there is a cached image") {
                        beforeEach {
                            mockUserDefaults.when { $0.object(forKey: any()) }.thenReturn(dependencies.date)
                            mockStorage
                                .when { $0.getOpenGroupImage(for: any(), on: any()) }
                                .thenReturn(Data([2, 3, 4]))
                        }
                        
                        it("retrieves the cached image") {
                            var result: Data?
                            
                            let promise = OpenGroupManager
                                .roomImage(
                                    1,
                                    for: "testRoom",
                                    on: OpenGroupAPI.defaultServer,
                                    using: dependencies
                                )
                                .done { result = $0 }
                            promise.retainUntilComplete()
                            
                            expect(promise.isFulfilled).toEventually(beTrue(), timeout: .milliseconds(50))
                            expect(result).toEventually(equal(Data([2, 3, 4])), timeout: .milliseconds(50))
                        }
                        
                        it("fetches a new image if the cached on is older than a week") {
                            mockUserDefaults
                                .when { $0.object(forKey: any()) }
                                .thenReturn(
                                    Date(timeIntervalSince1970:
                                        (dependencies.date.timeIntervalSince1970 - (7 * 24 * 60 * 60) - 1)
                                    )
                                )
                            
                            var result: Data?
                            
                            let promise = OpenGroupManager
                                .roomImage(
                                    1,
                                    for: "testRoom",
                                    on: OpenGroupAPI.defaultServer,
                                    using: dependencies
                                )
                                .done { result = $0 }
                            promise.retainUntilComplete()
                            
                            expect(promise.isFulfilled).toEventually(beTrue(), timeout: .milliseconds(50))
                            expect(result).toEventually(equal(Data([1, 2, 3])), timeout: .milliseconds(50))
                        }
                    }
                }
            }
            
            // MARK: - --parseOpenGroup
            
            context("when parsing an open group url") {
                it("handles the example urls correctly") {
                    let validUrls: [String] = [
                         "https://sessionopengroup.co/r/main?public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c",
                         "https://sessionopengroup.co/main?public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c",
                         "http://sessionopengroup.co/r/main?public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c",
                         "http://sessionopengroup.co/main?public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c",
                         "sessionopengroup.co/main?public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c",
                         "sessionopengroup.co/r/main?public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c",
                         "https://143.198.213.225:443/r/main?public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c",
                         "https://143.198.213.225:443/main?public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c",
                         "143.198.213.255:80/main?public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c",
                         "143.198.213.255:80/r/main?public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c"
                    ]
                    let processedValues: [(room: String, server: String, publicKey: String)] = validUrls
                        .map { OpenGroupManager.parseOpenGroup(from: $0) }
                        .compactMap { $0 }
                    let processedRooms: [String] = processedValues.map { $0.room }
                    let processedServers: [String] = processedValues.map { $0.server }
                    let processedPublicKeys: [String] = processedValues.map { $0.publicKey }
                    let expectedRooms: [String] = [String](repeating: "main", count: 10)
                    let expectedServers: [String] = [
                        "https://sessionopengroup.co",
                        "https://sessionopengroup.co",
                        "http://sessionopengroup.co",
                        "http://sessionopengroup.co",
                        "http://sessionopengroup.co",
                        "http://sessionopengroup.co",
                        "https://143.198.213.225:443",
                        "https://143.198.213.225:443",
                        "http://143.198.213.255:80",
                        "http://143.198.213.255:80"
                    ]
                    let expectedPublicKeys: [String] = [String](
                        repeating: "658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c",
                        count: 10
                    )
                    
                    expect(processedValues.count).to(equal(validUrls.count))
                    expect(processedRooms).to(equal(expectedRooms))
                    expect(processedServers).to(equal(expectedServers))
                    expect(processedPublicKeys).to(equal(expectedPublicKeys))
                }
                
                it("handles the r prefix if present") {
                    let info = OpenGroupManager.parseOpenGroup(
                        from: [
                            "https://sessionopengroup.co/r/main?",
                            "public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c"
                        ].joined()
                    )
                    
                    expect(info?.room).to(equal("main"))
                    expect(info?.server).to(equal("https://sessionopengroup.co"))
                    expect(info?.publicKey).to(equal("658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c"))
                }
                
                it("fails if there is no room") {
                    let info = OpenGroupManager.parseOpenGroup(
                        from: [
                            "https://sessionopengroup.co?",
                            "public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c"
                        ].joined()
                    )
                    
                    expect(info?.room).to(beNil())
                    expect(info?.server).to(beNil())
                    expect(info?.publicKey).to(beNil())
                }
                
                it("fails if there is no public key parameter") {
                    let info = OpenGroupManager.parseOpenGroup(
                        from: "https://sessionopengroup.co/r/main"
                    )
                    
                    expect(info?.room).to(beNil())
                    expect(info?.server).to(beNil())
                    expect(info?.publicKey).to(beNil())
                }
                
                it("fails if the public key parameter is not 64 characters") {
                    let info = OpenGroupManager.parseOpenGroup(
                        from: [
                            "https://sessionopengroup.co/r/main?",
                            "public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231"
                        ].joined()
                    )
                    
                    expect(info?.room).to(beNil())
                    expect(info?.server).to(beNil())
                    expect(info?.publicKey).to(beNil())
                }
                
                it("fails if the public key parameter is not a hex string") {
                    let info = OpenGroupManager.parseOpenGroup(
                        from: [
                            "https://sessionopengroup.co/r/main?",
                            "public_key=!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                        ].joined()
                    )
                    
                    expect(info?.room).to(beNil())
                    expect(info?.server).to(beNil())
                    expect(info?.publicKey).to(beNil())
                }
                
                it("maintains the same TLS") {
                    let server1 = OpenGroupManager.parseOpenGroup(
                        from: [
                            "sessionopengroup.co/r/main?",
                            "public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c"
                        ].joined()
                    )?.server
                    let server2 = OpenGroupManager.parseOpenGroup(
                        from: [
                            "http://sessionopengroup.co/r/main?",
                            "public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c"
                        ].joined()
                    )?.server
                    let server3 = OpenGroupManager.parseOpenGroup(
                        from: [
                            "https://sessionopengroup.co/r/main?",
                            "public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c"
                        ].joined()
                    )?.server
                    
                    expect(server1).to(equal("http://sessionopengroup.co"))
                    expect(server2).to(equal("http://sessionopengroup.co"))
                    expect(server3).to(equal("https://sessionopengroup.co"))
                }
                
                it("maintains the same port") {
                    let server1 = OpenGroupManager.parseOpenGroup(
                        from: [
                            "https://sessionopengroup.co/r/main?",
                            "public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c"
                        ].joined()
                    )?.server
                    let server2 = OpenGroupManager.parseOpenGroup(
                        from: [
                            "https://sessionopengroup.co:1234/r/main?",
                            "public_key=658d29b91892a2389505596b135e76a53db6e11d613a51dbd3d0816adffb231c"
                        ].joined()
                    )?.server
                    
                    expect(server1).to(equal("https://sessionopengroup.co"))
                    expect(server2).to(equal("https://sessionopengroup.co:1234"))
                }
            }
        }
    }
}

// MARK: - Room Convenience Extensions

extension OpenGroupAPI.Room {
    func with(moderators: [String], admins: [String]) -> OpenGroupAPI.Room {
        return OpenGroupAPI.Room(
            token: self.token,
            name: self.name,
            roomDescription: self.roomDescription,
            infoUpdates: self.infoUpdates,
            messageSequence: self.messageSequence,
            created: self.created,
            activeUsers: self.activeUsers,
            activeUsersCutoff: self.activeUsersCutoff,
            imageId: self.imageId,
            pinnedMessages: self.pinnedMessages,
            admin: self.admin,
            globalAdmin: self.globalAdmin,
            admins: admins,
            hiddenAdmins: self.hiddenAdmins,
            moderator: self.moderator,
            globalModerator: self.globalModerator,
            moderators: moderators,
            hiddenModerators: self.hiddenModerators,
            read: self.read,
            defaultRead: self.defaultRead,
            defaultAccessible: self.defaultAccessible,
            write: self.write,
            defaultWrite: self.defaultWrite,
            upload: self.upload,
            defaultUpload: self.defaultUpload
        )
    }
}
