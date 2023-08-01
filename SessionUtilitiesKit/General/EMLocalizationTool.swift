// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit



public enum Language : Int {
    case English = 0
    case Chinese
//    case French
    //越南语
//    case Vietnamese
}

public class EMLocalizationTool {
    public static let shared = EMLocalizationTool()
    var bundle: Bundle?
    public var currentLanguage: Language = .English
    
    private let defaults = UserDefaults.standard
    
    func valueWithKey(key: String) -> String {
        let bundle = EMLocalizationTool.shared.bundle
        
        if let bundle = bundle {
            return NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: "", comment: "")
        } else {
            return NSLocalizedString(key, comment: "")
        }
    }
    
    public func setLanguage(language: Language) {
        if currentLanguage == language {
            return
        }
        defaults.set(String(language.rawValue), forKey: "language")
        currentLanguage = getLanguage()
    }
    
    public func checkLanguage() {
        currentLanguage = getLanguage()
    }
    
    private func getLanguage() -> Language {
        var type = Language.English
        if let language = defaults.value(forKey: "language") as? String {
            type = Language.init(rawValue: Int(language) ?? 1) ?? .English
        }else{
            type = getSystemLanguage()
        }
        guard let path = Bundle.main.path(forResource:self.getLanguageSysName(type) , ofType: "lproj") else{
            return type
        }
        bundle = Bundle(path: path)
        return type
    }
    
    func getLanguageSysName(_ type : Language) -> String {
        switch type {
        case .Chinese:
            return "zh_CN"
        case .English:
            return "en"
//        case .French:
//            return "fr"
//        case .Vietnamese:
//            return "vi"
        }
    }
    
    //提交到后端的类型
    func getHeaderLanguage() -> String {
        var language = self.getLanguageSysName(self.currentLanguage)
        if language == "zh-Hans" {
            language = "zh-Hans"
        }
        if language == "zh-HK" {
            language = "zh-Hant"
        }
        return language
    }
    
    func getSystemLanguage() -> Language {
        let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
        let str = String(describing: preferredLang)
        switch str {
        case "zh-Hans":
            return .Chinese
        case "en":
            return .English
//        case "fr":
//            return .French
//        case "vi":
//            return .Vietnamese
        default:
            return .English
        }
    }
    
    public class func getLanguageName(_ type : Language) -> String {
        switch type {
        case .Chinese:
            return "中文（简体）"
        case .English:
            return "English"
//        case .French:
//            return "français"
//        case .Vietnamese:
//            return "Tiếng Việt"
        }
    }
    
    public class func getLanguageSymbol(_ type : Language) -> String {
        switch type {
        case .Chinese:
            return "CNY"
//        case .ChineseTraditional:
//            return "HKD"
        case .English:
            return "USD"
//        case .French:
//            return "EUR"
//        case .Russian :
//            return "RUB"
//        case .Japanese:
//            return "JPY"
//        case .Korean:
//            return "KRW"
//        case .Vietnamese:
//            return "VND"
        }
    }
    
}

extension String {
//    var localized: String {
//        return EMLocalizationTool.shared.valueWithKey(key: self)
//    }
//    
//    func localized() -> String {
//        return EMLocalizationTool.shared.valueWithKey(key: self)
//    }
    
}
