// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import Alamofire

/// Closure type executed when the request is successful
typealias HTTPSuccessed = (_ JSON: Any) -> Void
/// Closure type executed when the request is failed
typealias HTTPFailed = (_ error: HTTPError) throws -> Void
/// Closure type executed when monitoring the upload or download progress of a request.
typealias HTTPProgress = (Progress) -> Void

enum HTTPReachabilityStatus {
    /// It is unknown whether the network is reachable.
    case unknown
    /// The network is not reachable.
    case notReachable
    /// The connection type is either over Ethernet or WiFi.
    case ethernetOrWiFi
    /// The connection type is a cellular connection.
    case cellular
}

class HTTPError: Error {
    /// Error code
    var code = -1
    /// Error description
    var localizedDescription: String

    init(code: Int, desc: String) {
        self.code = code
        self.localizedDescription = desc
    }
}

/// Type representing HTTP methods.
enum HTTPMethod {
    /// Common HTTP methods.
    case delete, get, patch, post, put
    
    static func methodWith(_ m: HTTPMethod) -> Alamofire.HTTPMethod {
        switch m {
        case .delete: return .delete
        case .get: return .get
        case .patch: return .patch
        case .post: return .post
        case .put: return .put
        }
    }
}

/// Normal data type `MIME Type`
enum HTTPDataMimeType: String {
    case JPEG = "image/jpeg"
    case PNG = "image/png"
    case GIF = "image/gif"
    case HEIC = "image/heic"
    case HEIF = "image/heif"
    case WEBP = "image/webp"
    case TIF = "image/tif"
    case JSON = "application/json"
}

/// HTTPMultipartData for upload datas, eg: images/photos
class HTTPMultipartData {
    /// The data to be encoded and appended to the form data.
    let data: Data
    /// Name to associate with the `Data` in the `Content-Disposition` HTTP header.
    let name: String
    /// Filename to associate with the `Data` in the `Content-Disposition` HTTP header.
    let fileName: String
    /// The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types
    /// see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
    let mimeType: String

    /// Create HTTPMultipartData
    /// - Parameters:
    ///   - data: The data to be encoded and appended to the form data.
    ///   - name: The name to be associated with the specified data.
    ///   - fileName: The filename to be associated with the specified data.
    ///   - mimeType: The MIME type of the specified data. eg: image/jpeg
    init(data: Data, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }

    /// Create HTTPMultipartData
    /// - Parameters:
    ///   - data: The data to be encoded and appended to the form data.
    ///   - name: The name to be associated with the specified data.
    ///   - fileName: The filename to be associated with the specified data.
    ///   - type: The MIME type of the specified data. eg: image/jpeg
    convenience init(data: Data, name: String, fileName: String, type: HTTPDataMimeType) {
        self.init(data: data, name: name, fileName: fileName, mimeType: type.rawValue)
    }
}
