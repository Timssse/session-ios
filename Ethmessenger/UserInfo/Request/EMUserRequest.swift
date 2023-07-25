// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit


struct UserInfoRequest: HTTPRequest {
    var url: String = "v0/users/main"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var address : String
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["user_address":address])
    }
}

struct UserTweetsRequest: HTTPRequest {
    var url: String = "v0/tweets/timeline"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var address : String
    
    var cursor : String
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["user_address":address,"cursor":cursor])
    }
}
