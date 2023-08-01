// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit


struct UserInfoRequest: HTTPRequest {
    var url: String = "v0/users/main"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var address : String
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["user_address":address])
    }
}

struct UserTweetsRequest: HTTPRequest {
    var url: String = "v0/tweets/timeline"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var address : String
    
    var cursor : String
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["user_address":address,"cursor":cursor])
    }
}

struct UserUpdateInfoRequest: HTTPRequest {
    var url: String = "v0/users/update"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var param : [String: Any]?
    @discardableResult
    func request() async throws -> Any{
        return try await self.fetchAwait(param)
    }
}
//粉丝
struct getUserFansRequest: HTTPRequest {
    var url: String = "v0/users/fans"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var page : Int
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["page":page])
    }
}
//关注
struct getUserFollowRequest: HTTPRequest {
    var url: String = "v0/users/follow"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var page : Int
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["page":page])
    }
}

//关注
struct UserFollowRequest: HTTPRequest {
    var url: String = "v0/users/follow"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var address : String
    
    @discardableResult
    func request() async throws -> Any{
        return try await self.fetchAwait(["user_address":address])
    }
}

//取消关注
struct CancelUserFollowRequest: HTTPRequest {
    var url: String = "v0/users/cancelFollow"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var address : String
    
    @discardableResult
    func request() async throws -> Any{
        return try await self.fetchAwait(["user_address":address])
    }
}
