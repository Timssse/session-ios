// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import Alamofire


/// Http request service
let http = NetworkingTool()

/// Network status notification
let kNetworkStatusNotification = NSNotification.Name("kNetworkStatusNotification")
let kNetworkTokenInvalidNotification = NSNotification.Name("kNetworkTokenInvalidNotification")

typealias HTTPJson = [String: Any]
typealias HTTPList = [[String: Any]]

/// Http core service
class NetworkingTool {
    
    /// The network status, `.unknown` by default, You need to call the `startMonitoring()` method
    var networkStatus: HTTPReachabilityStatus = .unknown
    
    /// Http service configration, call this method before any http service
    func configuration() {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        _session = Session(configuration: config,
                           requestQueue: nil,
                           serializationQueue: nil,
                           interceptor: nil,
                           redirectHandler: nil,
                           cachedResponseHandler: nil,
                           eventMonitors: [])
        
        startMonitoring()
    }
    
    func request(url: String,
                 method: Alamofire.HTTPMethod,
                 parameters: [String: Any]?,
                 headers: [String: String]? = nil,
                 cache: Bool,
                 encoding: ParameterEncoding = JSONEncoding.default) -> NetworkingRequest {
        let task = NetworkingRequest()

        var h: HTTPHeaders?
        if let tempHeaders = headers {
            h = HTTPHeaders(tempHeaders)
        }
        
        var cacher = ResponseCacher.doNotCache
        if cache == true {
            cacher = ResponseCacher.cache
        }

        task.request = _session.request(url,
                                        method: method,
                                        parameters: parameters,
                                        encoding: encoding,
                                        headers: h).cacheResponse(using: cacher).validate().responseJSON { [weak self] response in
            task.handleResponse(response: response)
            if let index = self?._taskQueue.firstIndex(of: task) {
                self?._taskQueue.remove(at: index)
            }
        }
        _taskQueue.append(task)
        return task
    }
    
    func upload(url: String,
                method: Alamofire.HTTPMethod = .post,
                parameters: [String: String]?,
                datas: [HTTPMultipartData],
                headers: [String: String]? = nil) -> NetworkingRequest {
        let task = NetworkingRequest()

        var h: HTTPHeaders?
        if let tempHeaders = headers {
            h = HTTPHeaders(tempHeaders)
        }

        task.request = _session.upload(multipartFormData: { (multipartData) in
            // 1.参数 parameters
            if let parameters = parameters {
                for p in parameters {
                    multipartData.append(p.value.data(using: .utf8)!, withName: p.key)
                }
            }
            // 2.数据 datas
            for d in datas {
                multipartData.append(d.data, withName: d.fileName)
            }
        }, to: url, method: method, headers: h).uploadProgress(queue: .main, closure: { (progress) in
            task.handleProgress(progress: progress)
        }).validate().responseJSON(completionHandler: { [weak self] response in
            task.handleResponse(response: response)

            if let index = self?._taskQueue.firstIndex(of: task) {
                self?._taskQueue.remove(at: index)
            }
        })
        
        _taskQueue.append(task)
        return task
    }

    func download(url: String,
                  method: Alamofire.HTTPMethod = .post,
                  parameters: [String: Any]?,
                  headers: [String: String]? = nil) -> NetworkingRequest {
        let task = NetworkingRequest()
        
        var h: HTTPHeaders?
        if let tempHeaders = headers {
            h = HTTPHeaders(tempHeaders)
        }
        
        let destination: DownloadRequest.Destination = { _, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory,in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename!)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        task.request = _session.download(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: h, to: destination).validate().responseData { [weak self] response in
            task.handleDownload(response: response)

            if let index = self?._taskQueue.firstIndex(of: task) {
                self?._taskQueue.remove(at: index)
            }
        }
        
        _taskQueue.append(task)
        return task
    }
    
    
    private var _session = AF
    /// Network reachability manager, The first call to method `startMonitoring()` will be initialized.
    private var _reachability: NetworkReachabilityManager?
    
    private var _taskQueue : [ NetworkingRequest ] = []
}

extension NetworkingTool {
    
    func startMonitoring() {
        if _reachability == nil {
            _reachability = NetworkReachabilityManager.default
        }

        _reachability?.startListening(onQueue: .main, onUpdatePerforming: { [unowned self] (status) in
            switch status {
            case .notReachable:
                self.networkStatus = .notReachable
            case .unknown:
                self.networkStatus = .unknown
            case .reachable(.ethernetOrWiFi):
                self.networkStatus = .ethernetOrWiFi
            case .reachable(.cellular):
                self.networkStatus = .cellular
            }
            // Sent notification
            NotificationCenter.default.post(name: kNetworkStatusNotification, object: nil)
        })
    }

    func stopMonitoring() {
        guard _reachability != nil else { return }
        _reachability?.stopListening()
    }
}

class NetworkingRequest: Equatable {
    /// Alamofire.DataRequest
    var request: Alamofire.Request?
    
    /// request response callback
    private var _successHandler: HTTPSuccessed?
    /// request failed callback
    private var _failedHandler: HTTPFailed?
    /// `ProgressHandler` provided for upload/download progress callbacks.
    private var _progressHandler: HTTPProgress?
        
    /// Handle request response
    func handleResponse(response: AFDataResponse<Any>) {
        switch response.result {
        case .failure(let error):
            if let closure = _failedHandler {
                SNLog("======" + error.localizedDescription)
                try? closure(HTTPError(code: error.responseCode ?? -1, desc: error.localizedDescription))
            }
        case .success(let JSON):
            let json = JSON as? [String: Any]
            guard let ok = json?["Code"] as? Int,
                  ok == 0,
                  let data = json?["Data"] else {
                if json?["Size"] != nil{
                    if let closure = _successHandler {
                        closure(json!)
                    }
                    clearReference()
                    return
                }
                
                if let closure = _failedHandler {
                    try? closure(HTTPError(code: -2, desc: json?["Msg"] as! String))
                }
                clearReference()
                return
            }
            
            if let closure = _successHandler {
                closure(data)
            }
        }
        clearReference()
    }
    
    /// Processing request progress (Only when uploading files)
    func handleProgress(progress: Foundation.Progress) {
        if let closure = _progressHandler {
            closure(progress)
        }
    }
    
    /// Handle download response
    func handleDownload(response: AFDownloadResponse<Data>) {
        switch response.result {
        case .success:
            guard let path = response.fileURL?.path,
                  !path.hasSuffix("action") else {
                if let closure = _failedHandler {
                    try? closure(HTTPError(code: -1, desc: LocalHttpDownloadError.localized))
                }
                return
            }
            
            if let closure = _successHandler {
                closure(["path": path])
            }
        case .failure(let error):
            if let closure = _failedHandler {
                try? closure(HTTPError(code: error.responseCode ?? -1, desc: error.localizedDescription))
            }
        }
    }
    
    @discardableResult
    func success(_ closure: @escaping HTTPSuccessed) -> Self {
        _successHandler = closure
        return self
    }

    @discardableResult
    func failed(_ closure: @escaping HTTPFailed) -> Self {
        _failedHandler = closure
        return self
    }
    
    func progress(closure: @escaping HTTPProgress) -> Self {
        _progressHandler = closure
        return self
    }
    
    func cancel() {
        request?.cancel()
    }
    
    func clearReference() {
        _successHandler = nil
        _failedHandler = nil
        _progressHandler = nil
    }
}

/// Equatable for `HWNetworkRequest`
extension NetworkingRequest {
    /// Returns a Boolean value indicating whether two values are equal.
    static func == (lhs: NetworkingRequest, rhs: NetworkingRequest) -> Bool {
        return lhs.request?.id == rhs.request?.id
    }
}

