// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation

struct CommunityConfigRequest: HTTPRequest {
    var url: String = "v0/configs"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    func request() async throws -> Any{
        return try await self.fetchAwait()
    }
}

struct CommunityNonceRequest: HTTPRequest {
    var url: String = "v0/nonce"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
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
    
    var urlType : RequestUrlType = .communit
    
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
    
    var urlType : RequestUrlType = .communit
    
    var cursor : String
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["cursor":cursor])
    }
}

struct CommunityFollowTwitterRequest: HTTPRequest {
    var url: String = "v0/tweets/follow"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var cursor : String
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["cursor":cursor])
    }
}

struct CommunityLikeRequest: HTTPRequest {
    var url: String = "v0/tweets/like"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var twAddress : String
    @discardableResult
    func request() async throws -> Any{
        return try await self.fetchAwait(["tw_address":twAddress])
    }
}

struct CommunityDetailRequest: HTTPRequest {
    var url: String = "v0/tweets/item"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var twId : String
    @discardableResult
    func request() async throws -> Any{
        return try await self.fetchAwait(["id":twId])
    }
}

struct CommunityCommentListRequest: HTTPRequest {
    var url: String = "v0/comment/list"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var twAddress : String
    
    var page : Int
    
    @discardableResult
    func request() async throws -> Any{
        return try await self.fetchAwait(["tw_address":twAddress,"page":page])
    }
}

struct CommunityCommentReleaseRequest: HTTPRequest {
    var url: String = "v0/comment/release"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var twAddress : String
    
    var content : String
    
    @discardableResult
    func request() async throws -> Any{
        return try await self.fetchAwait(["tw_address":twAddress,"content":content])
    }
}

struct CommunityCreateRequest: HTTPRequest {
    var url: String = "v0/tweets/create"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var forwardId : String?
    
    var content : String
    
    var attachment : String
    
    @discardableResult
    func request() async throws -> Any{
        return try await self.fetchAwait(["forwardId":forwardId ?? "","content":content,"attachment":attachment])
    }
}

//转发
struct CommunityReleaseRequest: HTTPRequest {
    var url: String = "v0/tweets/release"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var id : String
    
    var sign : String
    
    @discardableResult
    func request() async throws -> Any{
        return try await self.fetchAwait(["id":id,"sign":sign])
    }
}


struct CommunityUploadRequest: HTTPRequest {
    var url: String = "api/v0/add"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var datas : [HTTPMultipartData]
    
    @discardableResult
    func request() async throws -> Any{
        return try await self.uploadAwait(datas)
    }
}

struct CommunityReportRequest: HTTPRequest {
    var url: String = "v0/tweets/report"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var id : String
    
    @discardableResult
    func request() async throws -> Any{
        return try await self.fetchAwait(["id":id])
    }
}

struct CommunityLikeMeRequest: HTTPRequest {
    var url: String = "v0/users/likeMe"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var page : Int
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["page":page])
    }
}


struct CommunityReplyMeRequest: HTTPRequest {
    var url: String = "v0/users/commentMe"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var page : Int
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["page":page])
    }
}

struct CommunityRepostMeRequest: HTTPRequest {
    var url: String = "v0/users/forwardMe"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .communit
    
    var page : Int
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["page":page])
    }
}
