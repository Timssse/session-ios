// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import Combine
import GRDB
import LocalAuthentication
import DifferenceKit
import SessionUIKit
import SessionMessagingKit
import SessionUtilitiesKit


class PrivacySettingsViewModel: SessionTableViewModel<PrivacySettingsViewModel.NavButton, PrivacySettingsViewModel.Section, PrivacySettingsViewModel.Item> {
    private let shouldShowCloseButton: Bool
    
    // MARK: - Initialization
    
    init(shouldShowCloseButton: Bool = false) {
        self.shouldShowCloseButton = shouldShowCloseButton
        
        super.init()
    }
    
    // MARK: - Config
    
    enum NavButton: Equatable {
        case close
    }
    
    public enum Section: SessionTableSection {
        case customer
        case screenSecurity
        case blockedContacts
//        case readReceipts
//        case typingIndicators
//        case linkPreviews
//        case calls
        
        var title: String? {
            switch self {
                case .customer: return "LocalCustomSetting".localized()
                case .screenSecurity: return "PRIVACY_SECTION_SCREEN_SECURITY".localized()
                case .blockedContacts: return nil
//                case .readReceipts: return "PRIVACY_SECTION_READ_RECEIPTS".localized()
//                case .typingIndicators: return "PRIVACY_SECTION_TYPING_INDICATORS".localized()
//                case .linkPreviews: return "PRIVACY_SECTION_LINK_PREVIEWS".localized()
//                case .calls: return "PRIVACY_SECTION_CALLS".localized()
            }
        }
        
        var style: SessionTableSectionStyle { return .title }
    }
    
    public enum Item: Differentiable {
        case seedSite
        case httpProxy
        case socks5Proxy
        case screenLock
        case screenshotNotifications
        case blockedContacts
//        case readReceipts
//        case typingIndicators
//        case linkPreviews
//        case calls
    }
    
    // MARK: - Navigation
    
    override var leftNavItems: AnyPublisher<[NavItem]?, Never> {
        guard self.shouldShowCloseButton else { return Just([]).eraseToAnyPublisher() }
        
        return Just([
            NavItem(
                id: .close,
                image: UIImage(named: "X")?
                    .withRenderingMode(.alwaysTemplate),
                style: .plain,
                accessibilityIdentifier: "Close Button"
            ) { [weak self] in
                self?.dismissScreen()
            }
        ]).eraseToAnyPublisher()
    }
    
    // MARK: - Content
    
    override var title: String { "PRIVACY_TITLE".localized() }
    
    private var _settingsData: [SectionModel] = []
    public override var settingsData: [SectionModel] { _settingsData }
    
    public override var observableSettingsData: ObservableData { _observableSettingsData }
    
    /// This is all the data the screen needs to populate itself, please see the following link for tips to help optimise
    /// performance https://github.com/groue/GRDB.swift#valueobservation-performance
    ///
    /// **Note:** This observation will be triggered twice immediately (and be de-duped by the `removeDuplicates`)
    /// this is due to the behaviour of `ValueConcurrentObserver.asyncStartObservation` which triggers it's own
    /// fetch (after the ones in `ValueConcurrentObserver.asyncStart`/`ValueConcurrentObserver.syncStart`)
    /// just in case the database has changed between the two reads - unfortunately it doesn't look like there is a way to prevent this
    private lazy var _observableSettingsData: ObservableData = ValueObservation
        .trackingConstantRegion { db -> [SectionModel] in
            return [
                SectionModel(
                    model: .customer,
                    elements: [
                        SessionCell.Info(
                            id: .seedSite,
                            title: "LocalSeedSite".localized(),
                            subtitle: "LocalGetLastSeed".localized(),
                            onTap: { [weak self] in
                                self?.transitionToScreen(InputModal.init(title: "LocalSeedSite".localized(), content: "LocalPleaseInputSeedSite".localized()).confirmAction({ value in
                                    if value.hasPrefix("http"){
                                        CacheUtilites.shared.localSeed = value
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            self?.restartApp()
                                        }
                                        
                                    }
                                }), transitionType: .present)
                                return
                            }
                        ),
                        SessionCell.Info(
                            id: .httpProxy,
                            title: "HttpProxy",
                            subtitle: CacheUtilites.shared.localHttpsProxy.count > 10 ? CacheUtilites.shared.localHttpsProxy : "LocalHelpFastSeed".localized(),
                            rightAccessory: .toggle(.settingBool(key: .isHttpsProxy)),
                            inputInfo: InputModelInfo.init(title: "HttpProxy", content: "LocalHelpFastSeed".localized(),inputText: CacheUtilites.shared.localHttpsProxy),
                            onTap: { [weak self] in
                                Storage.shared.write { db in
                                    db[.isHttpsProxy] = !db[.isHttpsProxy]
                                }
                                return
                            }
                        ),
                        SessionCell.Info(
                            id: .socks5Proxy,
                            title: "Socks5Proxy",
                            subtitle: CacheUtilites.shared.localSocks5Proxy.count > 10 ? CacheUtilites.shared.localSocks5Proxy : "LocalSocks5Network".localized(),
                            rightAccessory: .toggle(.settingBool(key: .isSocks5Proxy)),
                            inputInfo: InputModelInfo.init(title: "Socks5Proxy", content: "LocalHelpFastSeed".localized(),inputText: CacheUtilites.shared.localSocks5Proxy,placeholder: "127.0.0.1:7890" , type: Setting.BoolKey.isSocks5Proxy),
                            onTap: { [weak self] in
                                Storage.shared.write { db in
                                    db[.isSocks5Proxy] = !db[.isSocks5Proxy]
                                }
                                return
                            }
                        )
                    ]
                ),
                SectionModel(
                    model: .screenSecurity,
                    elements: [
                        SessionCell.Info(
                            id: .screenLock,
                            title: "PRIVACY_SCREEN_SECURITY_LOCK_Ethmessenger_TITLE".localized(),
                            subtitle: "PRIVACY_SCREEN_SECURITY_LOCK_Ethmessenger_DESCRIPTION".localized(),
                            rightAccessory: .toggle(.settingBool(key: .isScreenLockEnabled)),
                            onTap: { [weak self] in
                                // Make sure the device has a passcode set before allowing screen lock to
                                // be enabled (Note: This will always return true on a simulator)
                                guard LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
                                    self?.transitionToScreen(
                                        ConfirmationModal(
                                            info: ConfirmationModal.Info(
                                                title: "SCREEN_LOCK_ERROR_LOCAL_AUTHENTICATION_NOT_AVAILABLE".localized(),
                                                cancelTitle: "BUTTON_OK".localized(),
                                                cancelStyle: .alert_text
                                            )
                                        ),
                                        transitionType: .present
                                    )
                                    return
                                }
                                
                                Storage.shared.write { db in
                                    db[.isScreenLockEnabled] = !db[.isScreenLockEnabled]
                                }
                            }
                        )
                    ]
                ),
                SectionModel(
                    model: .blockedContacts,
                    elements: [
                        SessionCell.Info(
                            id: .blockedContacts,
                            title: "CONVERSATION_SETTINGS_BLOCKED_CONTACTS_TITLE".localized(),
                            tintColor: .danger,
                            shouldHaveBackground: false,
                            onTap: { [weak self] in
                                self?.transitionToScreen(BlockedContactsViewController())
                            }
                        )
                    ]
                )
            ]
        }
        .removeDuplicates()
        .publisher(in: Storage.shared)
    
    
    private func restartApp(){
        self.transitionToScreen(ConfirmationModal(
            info: ConfirmationModal.Info(
                title: LocalTips.localized(),
                body: .text("LocalRestartTips".localized()),
                confirmTitle: LocalConfirm.localized(),
                cancelTitle: LocalCancel.localized(),
                cancelStyle: .alert_text,
                onConfirm: { _ in
                    exit(0)
                }
            )
        ),transitionType: .present)
    }
    
    // MARK: - Functions

    public override func updateSettings(_ updatedSettings: [SectionModel]) {
        self._settingsData = updatedSettings
    }
    
    
    
    
}
