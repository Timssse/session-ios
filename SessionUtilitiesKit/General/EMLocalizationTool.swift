// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit



enum Language : Int {
    case English = 0
    case Chinese
//    case French
    //越南语
//    case Vietnamese
}

class EMLocalizationTool {
    static let shared = EMLocalizationTool()
    var bundle: Bundle?
    var currentLanguage: Language = .English
    
    private let defaults = UserDefaults.standard
    
    func valueWithKey(key: String) -> String {
        let bundle = EMLocalizationTool.shared.bundle
        if let bundle = bundle {
            return NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: "", comment: "")
        } else {
            return NSLocalizedString(key, comment: "")
        }
    }
    
    func setLanguage(language: Language) {
        if currentLanguage == language {
            return
        }
        defaults.set(String(language.rawValue), forKey: "language")
        currentLanguage = getLanguage()
    }
    
    func checkLanguage() {
        currentLanguage = getLanguage()
    }
    
    private func getLanguage() -> Language {
        var type = Language.English
        if let language = defaults.value(forKey: "language") as? String {
            type = Language.init(rawValue: Int(language) ?? 1) ?? .English
        }else{
            type = getSystemLanguage()
        }
        if let path = Bundle.main.path(forResource:self.getLanguageSysName(type) , ofType: "lproj") {
            bundle = Bundle(path: path)
        }
        return type
    }
    
    func getLanguageSysName(_ type : Language) -> String {
        switch type {
        case .Chinese:
            return "zh-Hans"
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
    
    class func getLanguageName(_ type : Language) -> String {
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
