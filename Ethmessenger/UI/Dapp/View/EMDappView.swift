// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import WalletCore
import WebKit
import web3swift
import Web3Core

enum DAppMethod: String, Decodable, CaseIterable {
    case signRawTransaction
    case signTransaction
    case signMessage
    case signTypedMessage
    case signPersonalMessage
    case ecRecover
    case requestAccounts
    case watchAsset
    case addEthereumChain
    case switchEthereumChain // legacy compatible
    case switchChain
}

extension WKScriptMessage {
    var json: [String: Any] {
        if let string = body as? String,
            let data = string.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = object as? [String: Any] {
            return dict
        } else if let object = body as? [String: Any] {
            return object
        }
        return [:]
    }
}


extension TrustWeb3Provider {
    static func createEthereum(address: String, chainId: Int, rpcUrl: String) -> TrustWeb3Provider {
        return TrustWeb3Provider(config: .init(ethereum: .init(address: address, chainId: chainId, rpcUrl: rpcUrl)))
    }
}

class EMDappView: UIView {
    private var isContractWallet = false
    var accountModel : EMAccount!
    var dapp : EMDappModel!
    var gasPrice : String = "3"
    
    convenience init(account:EMAccount,dapp:EMDappModel) {
        self.init()
        self.accountModel = account
        self.dapp = dapp
        guard let url = URL(string: dapp.url) else{
            return
        }
        self.webView.load(URLRequest.init(url: url))
    }
    
    lazy var current : TrustWeb3Provider = {
        var current: TrustWeb3Provider = TrustWeb3Provider(config: .init(ethereum: TrustWeb3Provider.Config.EthereumConfig(
            address: self.accountModel.address,
            chainId: self.accountModel.chain.chainId,
            rpcUrl: self.accountModel.chain.rpc
        )))
        return current
    }()
    
    public lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsLinkPreview = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true;
        self.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        return webView
    }()
    
    private lazy var config: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.addUserScript(current.providerScript)
        controller.addUserScript(current.injectScript)
        controller.add(self, name: TrustWeb3Provider.scriptHandlerName)
        config.userContentController = controller
        config.allowsInlineMediaPlayback = true
        return config
    }()
    
    lazy var loadingBar: UIView = {
        let view = UIView ()
        view.layer.cornerRadius = 2.0
        self.webView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.top.equalTo(self.webView)
            make.left.equalTo(self.webView)
            make.width.equalTo(0.0)
            make.height.equalTo(4.0)
        }
        return view
    }()

    func removeMessageHandler(){
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: TrustWeb3Provider.scriptHandlerName)
        self.webView.uiDelegate = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            if self.webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.loadingBar.alpha = 0.0
                    self.loadingBar.snp.updateConstraints { (make) in
                        make.width.equalTo(self.webView.frame.size.width)
                    }
                    self.layoutIfNeeded()
                }) { (_) in
                    self.loadingBar.snp.updateConstraints { (make) in
                        make.width.equalTo(0.0)
                    }
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.loadingBar.alpha = 1.0
                    let width = self.webView.frame.size.width * CGFloat(self.webView.estimatedProgress)
                    self.loadingBar.snp.updateConstraints { (make) in
                        make.width.equalTo(width)
                    }
                    self.layoutIfNeeded()
                }
            }
        }
    }
}

//MARK: 弹窗
extension EMDappView: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertVC = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "LocalConfirm".localized, style: .default) { (action) in
            completionHandler()
        }
        alertVC.addAction(action)
        UIUtil.visibleVC()?.present(alertVC, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertVC = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel) { (action) in
            completionHandler(false)
        }
        let deleteAction = UIAlertAction(title: "LocalConfirm".localized, style: .default) { (action) in
            completionHandler(true)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(deleteAction)
        UIUtil.visibleVC()?.present(alertVC, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            completionHandler(textField?.text)
        }))
        UIUtil.visibleVC()?.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
}

extension EMDappView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
}

extension EMDappView{
    func getParamter(first: String,second: String, url: String) -> String {
        var str = ""
        let arry1 = url.components(separatedBy: first)
        if arry1.count == 2 {
            if second.count == 0 {
                return arry1[1]
            }
            let str2 = arry1[1]
            let arry2 = str2.components(separatedBy: second)
            if arry2.count == 2 {
                str = arry2[0]
            }
        }else if arry1.count == 1{
            str = arry1[0]
        }
        return str
    }
}

extension EMDappView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let json = message.json
        guard
            let method = extractMethod(json: json),
            let id = json["id"] as? Int64,
            let network = extractNetwork(json: json)
        else {
            return
        }
        switch method {
        case .requestAccounts:
            handleRequestAccounts(network: network, id: id)
            break
        case .signTransaction:
//            Task{
//               await sendTransaction(dic:json,id: id)
//            }
            break
        case .signRawTransaction:
            break
        case .signMessage:
            guard let data = extractMessage(json: json) else {
                debugPrint("data is missing")
                return
            }
            switch network {
            case .ethereum:
                handleSignMessage(id: id, data: data, addPrefix: false)
            default:
                break
            }
        case .signPersonalMessage:
            guard let data = extractMessage(json: json) else {
                print("data is missing")
                return
            }
            handleSignMessage(id: id, data: data, addPrefix: true)
        case .signTypedMessage:
            guard
                let data = extractMessage(json: json),
                let raw = extractRaw(json: json)
            else {
                print("data or raw json is missing")
                return
            }
            handleSignTypedMessage(id: id, data: data, raw: raw)
        case .ecRecover:
            guard let tuple = extractSignature(json: json) else {
                print("signature or message is missing")
                return
            }
            let recovered = ecRecover(signature: tuple.signature, message: tuple.message) ?? ""
            print(recovered)
            DispatchQueue.main.async {
                self.webView.tw.send(network: .ethereum, result: recovered, to: id)
            }
        case .addEthereumChain:
//            guard let (chainId, _, _) = extractChainInfo(json: json) else {
//                return
//            }
//            let account = WalletConfig.shared.hasChain(chainId)
//            if account {
//                handleSwitchEthereumChain(id: id, chainId: chainId)
//            } else {
//                ///不支持这条链
//                self.webView.tw.send(network: .ethereum, error: "Canceled", to: id)
//            }
            break
            
        case .switchChain, .switchEthereumChain:
            if (network == .ethereum){
                guard
                    let chainId = extractEthereumChainId(json: json)
                else {
                    return
                }
//                let account = WalletConfig.shared.hasChain(chainId)
//                if account {
//                    handleSwitchEthereumChain(id: id, chainId: chainId)
//                } else {
//                    ///不支持这条链
//                    self.webView.tw.send(network: .ethereum, error: "Canceled", to: id)
//                }
                break
            }
        default:
            break
        }
    }
}


extension EMDappView{
    
    private func ecRecover(signature: Data, message: Data) -> String? {
        let data = ethereumMessage(for: message)
        let hash = data.sha3(.keccak256) //Hash.keccak256(data: data)
        guard let publicKey = PublicKey.recover(signature: signature, message: hash),
              PublicKey.isValid(data: publicKey.data, type: publicKey.keyType) else {
            return nil
        }
        return nil
    }
    
    private func ethereumMessage(for data: Data) -> Data {
        let prefix = "\u{19}Ethereum Signed Message:\n\(data.count)".data(using: .utf8)!
        return prefix + data
    }
    
    private func extractMethod(json: [String: Any]) -> DAppMethod? {
        guard
            let name = json["name"] as? String
        else {
            return nil
        }
        return DAppMethod(rawValue: name)
    }
    
    private func extractNetwork(json: [String: Any]) -> ProviderNetwork? {
        guard
            let network = json["network"] as? String
        else {
            return nil
        }
        return ProviderNetwork(rawValue: network)
    }
    
    private func extractMessage(json: [String: Any]) -> Data? {
        guard
            let params = json["object"] as? [String: Any],
            let string = params["data"] as? String
        else {
            return nil
        }
        return Data(hex: string)
    }
    
    private func extractSignature(json: [String: Any]) -> (signature: Data, message: Data)? {
        guard
            let params = json["object"] as? [String: Any],
            let signature = params["signature"] as? String,
            let message = params["message"] as? String
        else {
            return nil
        }
        return (Data(hex: signature), Data(hex: message))
    }
    
    private func extractRaw(json: [String: Any]) -> String? {
        guard
            let params = json["object"] as? [String: Any],
            let raw = params["raw"] as? String
        else {
            return nil
        }
        return raw
    }
    
    private func extractChainInfo(json: [String: Any]) ->(chainId: Int, name: String, rpcUrls: [String])? {
        guard
            let params = json["object"] as? [String: Any],
            let string = params["chainId"] as? String,
            let chainId = Int(String(string.dropFirst(2)), radix: 16),
            let name = params["chainName"] as? String,
            let urls = params["rpcUrls"] as? [String]
        else {
            return nil
        }
        return (chainId: chainId, name: name, rpcUrls: urls)
    }
    
    private func extractEthereumChainId(json: [String: Any]) -> Int? {
        guard
            let params = json["object"] as? [String: Any],
            let string = params["chainId"] as? String,
            let chainId = Int(String(string.dropFirst(2)), radix: 16),
            chainId > 0
        else {
            return nil
        }
        return chainId
    }
    
    func handleSignMessage(id: Int64, data: Data, addPrefix: Bool) {
        let signed = self.signMessage(data, addPrefix: addPrefix) ?? ""
        self.webView.tw.send(network: .ethereum, result:signed.add0x, to: id)
    }
    
    func signMessage(_ data : Data,addPrefix: Bool = true) -> String?{
        if (addPrefix){
            return signPersonalMessage(data)
        }
        let privateKey = WalletCore.PrivateKey(data: Data(hex: self.accountModel.privateKey))
        guard var signed = privateKey?.sign(digest: data, curve: Curve.secp256k1) else{
            return nil
        }
        signed[64] += 27
        return signed.hexEncoded
    }
    
    func signPersonalMessage(_ data : Data) -> String?{
        guard let keystore = try! EthereumKeystoreV3(privateKey: Data(hex: self.accountModel.privateKey),password: "")else{
            return nil
        }
        guard let result = try? Web3Signer.signPersonalMessage(data, keystore: keystore, account: keystore.addresses![0], password: "") else{
            return nil
        }
        return result.hexEncoded
    }
    
    //设置账户
    func handleRequestAccounts(network: ProviderNetwork, id: Int64) {
        self.webView.tw.set(network: network.rawValue, address: self.accountModel.address)
        self.webView.tw.send(network: network, results: [self.accountModel.address], to: id)
    }
    
    func handleSignTypedMessage(id: Int64, data: Data, raw: String) {
        let signed = self.signMessage(data, addPrefix: false) ?? ""
        self.webView.tw.send(network: .ethereum, result:signed.add0x, to: id)
    }
    
    
    
}
