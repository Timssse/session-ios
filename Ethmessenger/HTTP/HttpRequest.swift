// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import Alamofire

enum RequestUrlType{
    case communit
    case wallet
    case customer
}

/// API interface protocol
protocol HTTPRequest {
    /// API URL address
    var url: String { get }
    
    var urlType : RequestUrlType {get}
    /// Type representing HTTP methods.
    var method: HTTPMethod { get }
    /// Custom headers
    var headers: [String: String]? { get }
}

extension HTTPRequest {
    func fetchAwait(_ parameters: [String: Any]? = nil) async throws -> Any {
        try await withCheckedThrowingContinuation({ continuation in
            fetch(parameters).success { data in
                continuation.resume(returning: data)
            }.failed { error in
                debugPrint("HTTP error:"+error.localizedDescription)
                continuation.resume(throwing: error)
            }
        })
    }
    
    func fetchWithCacheAwait(_ parameters: [String: Any]? = nil) async throws -> Any {
        try await withCheckedThrowingContinuation({ continuation in
            fetchWithCache(parameters).success { data in
                continuation.resume(returning: data)
            }.failed { error in
                debugPrint("HTTP error:"+error.localizedDescription)
                continuation.resume(throwing: error)
            }
        })
    }
    
    func fetchBodyAwait(_ body: Data) async throws -> Any {
        try await withCheckedThrowingContinuation({ continuation in
            fetchBody(body)?.success { data in
                continuation.resume(returning: data)
            }.failed { error in
                debugPrint("HTTP error:"+error.localizedDescription)
                continuation.resume(throwing: error)
            }
        })
    }
    
    func uploadAwait(_ datas: [HTTPMultipartData], parameters: [String: String]? = nil) async throws -> Any {
        try await withCheckedThrowingContinuation({ continuation in
            upload(datas,parameters: parameters).success { data in
                continuation.resume(returning: data)
            }.failed { error in
                debugPrint("HTTP error:"+error.localizedDescription)
                continuation.resume(throwing: error)
            }
        })
    }
}

extension HTTPRequest {
    func fetch(_ parameters: [String: Any]? = nil) -> NetworkingRequest {
        let totalHeaders = headers == nil ? commonHeaders() : commonHeaders().merging(headers!) { $1 }
        let method = HTTPMethod.methodWith(self.method)
        let url = baseUrl() + self.url
        let task = http.request(url: url, method: method, parameters: parameters, headers: totalHeaders, cache: false, encoding: method == .get ? URLEncoding.default : URLEncoding.default)
        return task
    }
    
    func fetchWithCache(_ parameters: [String: Any]? = nil) -> NetworkingRequest {
        let totalHeaders = headers == nil ? commonHeaders() : commonHeaders().merging(headers!) { $1 }
        let method = HTTPMethod.methodWith(self.method)
        let url = baseUrl() + self.url
        let task = http.request(url: url, method: method, parameters: parameters, headers: totalHeaders, cache: true, encoding: method == .get ? URLEncoding.default : URLEncoding.default)
        return task
    }
    
    func fetchBody(_ body : Data) -> NetworkingRequest? {
        let url = baseUrl() + self.url
        guard let turl = URL(string: url) else {
            return nil
        }
        var request = URLRequest.init(url: turl)
        request.httpBody = body
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        let task = http.request(request: request)
        return task
    }
    
    func upload(_ datas: [HTTPMultipartData], parameters: [String: String]? = nil) -> NetworkingRequest {
        let totalHeaders = headers == nil ? commonHeaders() : commonHeaders().merging(headers!) { $1 }
        let method = HTTPMethod.methodWith(self.method)
        let url = EMCommunityConfigEntity.share.IpfsHost + self.url
        let task = http.upload(url: url, method: method, parameters: parameters, datas: datas, headers: totalHeaders)
        return task
    }
    
    func download(_ parameters: [String: Any]? = nil) -> NetworkingRequest {
        let totalHeaders = headers == nil ? commonHeaders() : commonHeaders().merging(headers!) { $1 }
        let method = HTTPMethod.methodWith(self.method)
        let url = baseUrl() + self.url
        let task = http.download(url: url, method: method, parameters: parameters, headers: totalHeaders)
        return task
    }
    
    func commonHeaders() -> [String: String] {
        var header : [String:String] = [:]
        if let token = CacheUtilites.shared.localCommunityToken {
            header["x-token"] = token
        }
        return header
    }
    
    func baseUrl() -> String {
        if urlType == .wallet {
            return "https://fairapi.dappconnect.io/api/v1/"
        }
        if urlType == .customer {
            return ""
        }
        return "https://api-v2.ethtweet.io/api/"
    }
}

