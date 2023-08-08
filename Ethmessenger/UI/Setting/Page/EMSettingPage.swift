// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionMessagingKit
import GRDB
import DifferenceKit
import Combine
import SessionUIKit
import SessionUtilitiesKit
class EMSettingPage: BaseVC,ThemedNavigation {
    typealias ObservableData = AnyPublisher<[EMSettingSectionModel], Error>
    private var dataChangeCancellable: AnyCancellable?
    var dataArr : [EMSettingSectionModel] = []
    var profile : Profile?
    override func viewDidLoad() {
        super.viewDidLoad()
//        updateNavBarButtons()
        self.title = "Set"
    }
    
    lazy var _observableSettingsData : ObservableData = ValueObservation.trackingConstantRegion {[weak self] db -> [EMSettingSectionModel] in
        self?.profile = Profile.fetchOrCreateCurrentUser(db)
        self?.dataArr = self?.createData() ?? []
        return self?.dataArr ?? []
    }.removeDuplicates().publisher(in: Storage.shared)
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObservingChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObservingChanges()
    }
    
    
    lazy var tableView : UITableView = {
        let tableView = EMTableView(delegate: self, dataSource: self, backgroundColor: .navBack)
        tableView.register(EMUserSettingCell.self, forCellReuseIdentifier: "EMUserSettingCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -safeBottomH, right: 0)
        tableView.tableFooterView = self.exitView
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return tableView
    }()
    
    lazy var exitView : UIView = {
        let view = UIView(.conversationButton_background)
        view.frame = CGRect(x: 0, y: 0, width: Screen_width, height: 75.w + safeBottomH)
        let exit = UIButton(title:LocalExit.localized(),font: UIFont.Bold(size: 18),color: ThemeValue.danger)
        exit.frame = CGRect(x: 0, y: 0, width: Screen_width, height: 75.w)
        exit.addTarget(self, action: #selector(onclickExit), for: .touchUpInside)
        view.addSubview(exit)
        return view
    }()
    
    
    func createData() -> [EMSettingSectionModel]{
        return [
            EMSettingSectionType.createSection(.settings),
            EMSettingSectionType.createSection(.globalChatSetting)
        ]
    }
    
    
}

extension EMSettingPage{
    
    private func startObservingChanges() {
        // Start observing for data changes
        dataChangeCancellable = _observableSettingsData.receiveOnMain(
                immediately: false
        ).sink(receiveCompletion: { _ in
            
        }, receiveValue: { _ in
            self.tableView.reloadData()
        })
    }
    
    private func stopObservingChanges() {
        // Stop observing database changes
        dataChangeCancellable?.cancel()
    }
    
    @objc func onclickQrcode(){
        self.push(QRCodeVC())
    }
    
    @objc func onclickExit(){
        EMAlert.alert(.tip)?
            .title(LocalExit.localized())
            .content(LocalExitTips.localized())
            .confirm(LocalCancel.localized())
            .cancel(LocalConfirm.localized())
            .cancelAction { [weak self] in
                self?.clearDeviceOnly()
            }.popup()
    }
    
    
    private func clearDeviceOnly() {
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { [weak self] _ in
            Storage.shared
                .writeAsync { db in try MessageSender.syncConfiguration(db, forceSyncNow: true) }
                .ensure(on: DispatchQueue.main) {
                    self?.deleteAllLocalData()
                    self?.dismiss(animated: true, completion: nil) // Dismiss the loader
                }
                .retainUntilComplete()
        }
    }
    
//    private func clearEntireAccount() {
//        ModalActivityIndicatorViewController
//            .present(fromViewController: self, canCancel: false) { [weak self] _ in
//                SnodeAPI.clearAllData()
//                    .done(on: DispatchQueue.main) { confirmations in
//                        self?.dismiss(animated: true, completion: nil) // Dismiss the loader
//
//                        let potentiallyMaliciousSnodes = confirmations.compactMap { $0.value == false ? $0.key : nil }
//
//                        if potentiallyMaliciousSnodes.isEmpty {
//                            self?.deleteAllLocalData()
//                        }
//                        else {
//                            let message: String
//                            if potentiallyMaliciousSnodes.count == 1 {
//                                message = String(format: "dialog_clear_all_data_deletion_failed_1".localized(), potentiallyMaliciousSnodes[0])
//                            }
//                            else {
//                                message = String(format: "dialog_clear_all_data_deletion_failed_2".localized(), String(potentiallyMaliciousSnodes.count), potentiallyMaliciousSnodes.joined(separator: ", "))
//                            }
//
//                            let modal: ConfirmationModal = ConfirmationModal(
//                                targetView: self?.view,
//                                info: ConfirmationModal.Info(
//                                    title: "ALERT_ERROR_TITLE".localized(),
//                                    body: .text(message),
//                                    cancelTitle: "BUTTON_OK".localized(),
//                                    cancelStyle: .alert_text
//                                )
//                            )
//                            self?.present(modal, animated: true)
//                        }
//                    }
//                    .catch(on: DispatchQueue.main) { error in
//                        self?.dismiss(animated: true, completion: nil) // Dismiss the loader
//
//                        let modal: ConfirmationModal = ConfirmationModal(
//                            targetView: self?.view,
//                            info: ConfirmationModal.Info(
//                                title: "ALERT_ERROR_TITLE".localized(),
//                                body: .text(error.localizedDescription),
//                                cancelTitle: "BUTTON_OK".localized(),
//                                cancelStyle: .alert_text
//                            )
//                        )
//                        self?.present(modal, animated: true)
//                    }
//            }
//    }
    
    private func deleteAllLocalData() {
        // Unregister push notifications if needed
        let isUsingFullAPNs: Bool = UserDefaults.standard[.isUsingFullAPNs]
        let maybeDeviceToken: String? = UserDefaults.standard[.deviceToken]
        
        if isUsingFullAPNs, let deviceToken: String = maybeDeviceToken {
            let data: Data = Data(hex: deviceToken)
            PushNotificationAPI.unregister(data).retainUntilComplete()
        }
        
        // Clear the app badge and notifications
        AppEnvironment.shared.notificationPresenter.clearAllNotifications()
        CurrentAppContext().setMainAppBadgeNumber(0)
        
        // Clear out the user defaults
        UserDefaults.removeAll()
        
        // Remove the cached key so it gets re-cached on next access
        General.cache.mutate { $0.encodedPublicKey = nil }
        
        // Clear the Snode pool
        SnodeAPI.clearSnodePool()
        
        // Stop any pollers
        (UIApplication.shared.delegate as? AppDelegate)?.stopPollers()
        
        // Call through to the SessionApp's "resetAppData" which will wipe out logs, database and
        // profile storage
        let wasUnlinked: Bool = UserDefaults.standard[.wasUnlinked]
        
        SessionApp.resetAppData {
            // Resetting the data clears the old user defaults. We need to restore the unlink default.
            UserDefaults.standard[.wasUnlinked] = wasUnlinked
        }
    }
    
}

extension EMSettingPage: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = self.dataArr[section]
        return data.cells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.dataArr[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMUserSettingCell", for: indexPath) as! EMUserSettingCell
        cell.model = data.cells[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.w
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 40.w))
        view.themeBackgroundColor = .navBack
        let bgView = UIView(.conversationButton_background)
        bgView.frame = view.bounds
        view.addSubview(bgView)
        
        if section == 0{
            bgView.dealCorner(type: .topLeftRight, corner: 20.w)
        }else{
            let line = UIView(.line)
            bgView.addSubview(line)
            line.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(25.w)
                make.right.equalToSuperview().offset(-25.w)
                make.top.equalToSuperview()
                make.height.equalTo(1)
            }
        }
        
        let lab = UILabel(font: UIFont.Bold(size: 16),textColor: .textPrimary,text: section == 1 ? "vc_settings_title".localized() : LocalChatSetting.localized())
        bgView.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.bottom.equalToSuperview()
        }
        
        
        return view
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.dataArr[indexPath.section]
        switch data.cells[indexPath.row].type{
        case .path :
            self.push(PathVC())
            break
        case .language :
            EMLanguageChangeView.show()
            break
        case .cleanCache :
            EMAlert.alert(.tip)?
                .title(LocalTips.localized())
                .content(LocalCleanCacheTips.localized())
                .confirm(LocalConfirm.localized())
                .cancel(LocalCancel.localized())
                .confirmAction {_ in
                    Task{
                        await EMCacheManager.share.cleanCache()
                        Toast.toast(hit: LocalCleanSuccess.localized())
                        self.dataArr = self.createData()
                        self.tableView.reloadData()
                    }
                }.popup()
            break
        case .privacy :
            self.push(SessionTableViewController(viewModel: PrivacySettingsViewModel()))
            break
        case .notification :
            self.push(SessionTableViewController(viewModel: NotificationSettingsViewModel()))
            break
        case .conversations :
            self.push(SessionTableViewController(viewModel: ConversationSettingsViewModel()))
            break
        case .message :
            self.push(MessageRequestsViewController())
            break
        case .autoDeleteMessage:
            
            if Storage.shared[Setting.BoolKey.trimOpenGroupMessagesOlderThanSixMonths]{
                Storage.shared.write { db in
                    db[.trimOpenGroupMessagesOlderThanSixMonths] = !db[.trimOpenGroupMessagesOlderThanSixMonths]
                }
                self.dataArr = self.createData()
                self.tableView.reloadData()
                return
            }
            EMAlert.alert(.tip)?
                .title(LocalTips.localized())
                .content(LocalAutoDeleteMessageTips.localized())
                .confirm(LocalConfirm.localized())
                .cancel(LocalCancel.localized())
                .confirmAction {_ in
                    Task{
                        Storage.shared.write { db in
                            db[.trimOpenGroupMessagesOlderThanSixMonths] = !db[.trimOpenGroupMessagesOlderThanSixMonths]
                        }
                        self.dataArr = self.createData()
                        self.tableView.reloadData()
                    }
                }.popup()
            break
        case .appearance :
//            self.push(AppearanceViewController())
            EMThemeModeView.show()
            break
        case .receiptRead:
            Storage.shared.write { db in
                db[.areReadReceiptsEnabled] = !db[.areReadReceiptsEnabled]
            }
            self.dataArr = self.createData()
            self.tableView.reloadData()
//            SessionCell.Info(
//                id: .readReceipts,
//                title: "PRIVACY_READ_RECEIPTS_TITLE".localized(),
//                subtitle: "PRIVACY_READ_RECEIPTS_DESCRIPTION".localized(),
//                rightAccessory: .toggle(.settingBool(key: .areReadReceiptsEnabled)),
//                onTap: {
//                    Storage.shared.write { db in
//                        db[.areReadReceiptsEnabled] = !db[.areReadReceiptsEnabled]
//                    }
//                }
//            )
            break
        case .inputTips:
            Storage.shared.write { db in
                db[.typingIndicatorsEnabled] = !db[.typingIndicatorsEnabled]
            }
            self.dataArr = self.createData()
            self.tableView.reloadData()
            break
        case .linkPreview:
            Storage.shared.write { db in
                db[.areLinkPreviewsEnabled] = !db[.areLinkPreviewsEnabled]
            }
            self.dataArr = self.createData()
            self.tableView.reloadData()
            break
        case .voiceAndVideoCall:
            
            if Storage.shared[Setting.BoolKey.areCallsEnabled]{
                Storage.shared.write { db in
                    db[.areCallsEnabled] = !db[.areCallsEnabled]
                }
                self.dataArr = self.createData()
                self.tableView.reloadData()
                return
            }
            EMAlert.alert()?
                .title("PRIVACY_CALLS_WARNING_TITLE".localized())
                .content("PRIVACY_CALLS_WARNING_DESCRIPTION".localized())
                .confirm(LocalConfirm.localized())
                .cancel(LocalCancel.localized())
                .confirmAction {_ in
                    Permissions.requestMicrophonePermissionIfNeeded()
                    Storage.shared.write { db in
                        db[.areCallsEnabled] = !db[.areCallsEnabled]
                    }
                    self.dataArr = self.createData()
                    self.tableView.reloadData()
                }.cancelAction {
                    
                }.popup()
            break
        case .invite :
            let invitation: String = "Hey, I've been using Ethmessager to chat with complete privacy and security. Come join me! Download it at https://ethmessenger.app/. My Session ID is \(profile?.id ?? "") !"
            self.present(UIActivityViewController(
                activityItems: [ invitation ],
                applicationActivities: nil
            ), animated: true)
            break
        case .website:
            UIApplication.shared.open(URL(string: "https://ethmessenger.app/")!,completionHandler: nil)
            break
//        case .recovery :
//            self.present(SeedModal(), animated: true)
//            break
//        case .help :
//            self.push(SessionTableViewController(viewModel: HelpViewModel()))
//            break
//        case .clean :
//            self.present(NukeDataModal(), animated: true)
//            break
        default:break
            
        
        }
    }
}
