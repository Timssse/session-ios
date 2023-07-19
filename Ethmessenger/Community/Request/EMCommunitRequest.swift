// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation

struct CommunityNonceRequest: HTTPRequest {
    var url: String = "v0/nonce"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var address : String
    
    var sign : String
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["user_address":address,"sign":sign])
    }
}

struct CommunityLoginRequest: HTTPRequest {
    var url: String = "v0/authorize"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var address : String
    
    var sign : String
    
    var nonce : String
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["user_address":address,"sign":sign,"nonce" : nonce])
    }
}

struct CommunityHomeRequest: HTTPRequest {
    var url: String = "v0/index"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var cursor : String
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["user_address":cursor])
    }
}

struct CommunityLikeRequest: HTTPRequest {
    var url: String = "v0/tweets/like"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var twAddress : String
    @discardableResult
    func request() async throws -> Any{
        return try await self.fetchAwait(["tw_address":twAddress])
    }
}
