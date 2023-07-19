// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionMessagingKit
import GRDB
import DifferenceKit
import Combine
import SessionUIKit

class EMChatSettingPage: BaseVC {
//    typealias SectionModel = ArraySection<SettingsViewModel.Section, SessionCell.Info<SettingsViewModel.Item>>
    typealias ObservableData = AnyPublisher<[EMSettingSectionModel], Error>
    private var dataChangeCancellable: AnyCancellable?
    let dependencies =  Dependencies()
    var viewModel : SessionThreadViewModel!
    var profile : Profile?
    var disappearingMessagesConfig : DisappearingMessagesConfiguration?
    var notificationSound : Preferences.Sound?
    var maybeThreadViewModel: SessionThreadViewModel?
    
    
    
    var dataArr : [EMSettingSectionModel] = []
    
    init(viewModel: SessionThreadViewModel) {
        self.viewModel = viewModel
        self.profile = viewModel.profile
        super.init(nibName: nil, bundle: nil)
    }
    
    lazy var _observableSettingsData : ObservableData = ValueObservation.trackingConstantRegion {[weak self,dependencies,threadId = self.viewModel.threadId] db -> [EMSettingSectionModel] in
        let userPublicKey: String = getUserHexEncodedPublicKey(db, dependencies: dependencies)
        self?.maybeThreadViewModel = try SessionThreadViewModel
            .conversationSettingsQuery(threadId: threadId, userPublicKey: userPublicKey)
            .fetchOne(db)
        let fallbackSound: Preferences.Sound = db[.defaultNotificationSound]
            .defaulting(to: Preferences.Sound.defaultNotificationSound)
        self?.notificationSound = try SessionThread
            .filter(id: threadId)
            .select(.notificationSound)
            .asRequest(of: Preferences.Sound.self)
            .fetchOne(db)
            .defaulting(to: fallbackSound)
        
        self?.disappearingMessagesConfig = try DisappearingMessagesConfiguration
            .fetchOne(db, id: threadId)
            .defaulting(to: DisappearingMessagesConfiguration.defaultWith(threadId))
        self?.dataArr = self?.createData() ?? []
        return self?.dataArr ?? []
    }.removeDuplicates().publisher(in: Storage.shared)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObservingChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObservingChanges()
    }
    
    override func layoutUI() {
        self.title = self.viewModel.threadVariant == .contact ? self.viewModel.displayName : "vc_group_settings_title".localized()
        let qrcodeItem = UIBarButtonItem(image: UIImage(named: "icon_chats_edit"), style: .done, target: self, action: #selector(onclickEditName))
        qrcodeItem.themeTintColor = .textPrimary
        navigationItem.rightBarButtonItem = self.viewModel.threadVariant == .contact ? qrcodeItem : nil
    }
    
    lazy var tableView : UITableView = {
        let tableView = EMTableView(delegate: self, dataSource: self, backgroundColor: .navBack)
        tableView.register(EMChatSettingUserInfoCell.self, forCellReuseIdentifier: "EMChatSettingUserInfoCell")
        tableView.register(EMSettingCell.self, forCellReuseIdentifier: "EMSettingCell")
        tableView.register(EMChatGroupInfoCell.self, forCellReuseIdentifier: "EMChatGroupInfoCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -safeBottomH, right: 0)
        let footerView = UIView(.conversationButton_background)
        footerView.frame = CGRect(x: 0, y: 0, width: Screen_width, height: 90.w)
        tableView.tableFooterView = footerView
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return tableView
    }()

    
    func createData() -> [EMSettingSectionModel] {
        if self.viewModel.threadVariant == .contact {
            return [
                EMSettingSectionType.createSection(.userInfo,profile: self.profile),
                EMSettingSectionType.createSection(.chatSettings,disappearingMessagesConfig: self.disappearingMessagesConfig,notificationSound: self.notificationSound,maybeThreadViewModel: self.maybeThreadViewModel)
            ]
        }
        if self.viewModel.threadVariant == .closedGroup {
            return [
                EMSettingSectionType.createSection(.groupInfo,profile: self.profile),
                EMSettingSectionType.createSection(.privateGroupSettings,disappearingMessagesConfig: self.disappearingMessagesConfig,notificationSound: self.notificationSound,maybeThreadViewModel: self.maybeThreadViewModel)
            ]
        }
        return [
            EMSettingSectionType.createSection(.userInfo,profile: self.profile),
            EMSettingSectionType.createSection(.openGroupSettings,disappearingMessagesConfig: self.disappearingMessagesConfig,notificationSound: self.notificationSound,maybeThreadViewModel: self.maybeThreadViewModel)
        ]
    }
    
    var currentUserIsClosedGroupAdmin: Bool {
        return viewModel.threadVariant == .closedGroup &&
        maybeThreadViewModel?.currentUserIsClosedGroupAdmin == true
    }
}

extension EMChatSettingPage{
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
    
    
    @objc func onclickEditName(){
        let inputView = InputModal(targetView: nil,info: InputModelInfo.init(title: "LocalEnterName".localized(), content: "")).confirmAction { value in
            self.updateName(value)
        }
        UIUtil.visibleVC()?.present(inputView, animated: true, completion: nil)
    }
    
    func updateName(_ name : String)  {
        let updatedNickname: String = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !updatedNickname.isEmpty else {
            UIUtil.visibleVC()?.present(ConfirmationModal(
                info: ConfirmationModal.Info(
                    title: "vc_settings_display_name_missing_error".localized(),
                    cancelTitle: "BUTTON_OK".localized(),
                    cancelStyle: .alert_text
                )
            ), animated: true)
            return
        }
        guard !ProfileManager.isToLong(profileName: updatedNickname) else {
            UIUtil.visibleVC()?.present(ConfirmationModal(
                info: ConfirmationModal.Info(
                    title: "vc_settings_display_name_too_long_error".localized(),
                    cancelTitle: "BUTTON_OK".localized(),
                    cancelStyle: .alert_text
                )
            ), animated: true)
            return
        }
        self.title = updatedNickname
        self.updateProfile(
            name: updatedNickname,
            profilePicture: nil,
            profilePictureFilePath: ProfileManager.profileAvatarFilepath(id: self.viewModel?.id ?? ""),
            isUpdatingDisplayName: true,
            isUpdatingProfilePicture: false
        )
    }
    
    private func updateProfile(
        name: String,
        profilePicture: UIImage?,
        profilePictureFilePath: String?,
        isUpdatingDisplayName: Bool,
        isUpdatingProfilePicture: Bool,
        onComplete: (() -> ())? = nil
    ) {
        ProfileManager.updateLocal(
            queue: DispatchQueue.global(qos: .default),
            profileName: name,
            image: profilePicture,
            imageFilePath: profilePictureFilePath,
            success: { db, updatedProfile in
                if isUpdatingDisplayName {
                    UserDefaults.standard[.lastDisplayNameUpdate] = Date()
                }

                if isUpdatingProfilePicture {
                    UserDefaults.standard[.lastProfilePictureUpdate] = Date()
                }

                try MessageSender.syncConfiguration(db, forceSyncNow: true).retainUntilComplete()

                // Wait for the database transaction to complete before updating the UI
                db.afterNextTransaction { _ in
                    
                }
            },
            failure: { error in
                DispatchQueue.main.async {
                    let isMaxFileSizeExceeded: Bool = (error == .avatarUploadMaxFileSizeExceeded)
                    
                    UIUtil.visibleVC()?.present(ConfirmationModal(
                        info: ConfirmationModal.Info(
                            title: (isMaxFileSizeExceeded ?
                                "Maximum File Size Exceeded" :
                                "Couldn't Update Profile"
                            ),
                            body: .text(isMaxFileSizeExceeded ?
                                "Please select a smaller photo and try again" :
                                "Please check your internet connection and try again"
                            ),
                            cancelTitle: "BUTTON_OK".localized(),
                            cancelStyle: .alert_text,
                            dismissType: .single
                        )
                    ), animated: true, completion: nil)
                }
            }
        )
    }
}

extension EMChatSettingPage: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArr.count
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
        if indexPath.section == 0{
            if self.viewModel.threadVariant == .contact{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EMChatSettingUserInfoCell", for: indexPath) as! EMChatSettingUserInfoCell
                cell.model = data.cells[indexPath.row].userInfo
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "EMChatGroupInfoCell", for: indexPath) as! EMChatGroupInfoCell
            cell.threadViewModel = self.viewModel
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMSettingCell", for: indexPath) as! EMSettingCell
        cell.model = data.cells[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 20.w
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: section == 0 ? 0 : 20.w))
        view.themeBackgroundColor = .navBack
        let bgView = UIView(.conversationButton_background)
        bgView.frame = view.bounds
        view.addSubview(bgView)
        bgView.dealCorner(type: .topLeftRight, corner: 20.w)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.dataArr[indexPath.section]
        let model = data.cells[indexPath.row]
        switch model.type{
        case .photo :
            self.push(MediaGalleryViewModel.createAllMediaViewController(
                threadId: self.viewModel.threadId,
                threadVariant: self.viewModel.threadVariant,
                focusedAttachmentId: nil
            ))
            break
        case .copyGroupUrl :
            guard
                let server: String = self.viewModel.openGroupServer,
                let roomToken: String = self.viewModel.openGroupRoomToken,
                let publicKey: String = self.viewModel.openGroupPublicKey
            else { return }
            
            UIPasteboard.general.string = OpenGroup.urlFor(
                server: server,
                roomToken: roomToken,
                publicKey: publicKey
            )
            break
        case .addMembers:
            self.present(UserSelectionVC(
                with: "vc_conversation_settings_invite_button_title".localized(),
                excluding: Set()
            ) { [weak self] selectedUsers in
                self?.addUsersToOpenGoup(
                    threadViewModel: self?.maybeThreadViewModel,
                    selectedUsers: selectedUsers
                )
            }, animated: true)
            break
        case .editGroup:
            self.push(EditClosedGroupVC(threadId: self.viewModel.threadId))
            break
        case .leaveGroup:
            self.present(ConfirmationModal(info: ConfirmationModal.Info(
                title: "leave_group_confirmation_alert_title".localized(),
                body: .attributedText({
                    if self.currentUserIsClosedGroupAdmin {
                        return NSAttributedString(string: "admin_group_leave_warning".localized())
                    }
                    let mutableAttributedString = NSMutableAttributedString(
                        string: String(
                            format: "leave_community_confirmation_alert_message".localized(),
                            self.maybeThreadViewModel?.displayName ?? ""
                        )
                    )
                    mutableAttributedString.addAttribute(
                        .font,
                        value: UIFont.boldSystemFont(ofSize: Values.smallFontSize),
                        range: (mutableAttributedString.string as NSString).range(of: self.maybeThreadViewModel?.displayName ?? "")
                    )
                    return mutableAttributedString
                }()),
                confirmTitle: "LEAVE_BUTTON_TITLE".localized(),
                confirmStyle: .danger,
                cancelStyle: .alert_text,
                onConfirm: { _ in
                    self.dependencies.storage.writeAsync { db in
                        try MessageSender.leave(db, groupPublicKey: self.viewModel.threadId, deleteThread: false)
                    }
                }
            )), animated: true)
            break
        case .notifyMentionsOnly:
            let newValue: Bool = !(self.maybeThreadViewModel?.threadOnlyNotifyForMentions == true)
            dependencies.storage.writeAsync { db in
                try SessionThread
                    .filter(id: self.viewModel.threadId)
                    .updateAll(
                        db,
                        SessionThread.Columns.onlyNotifyForMentions
                            .set(to: newValue)
                    )
            }
            break
        case .search :
            self.push(ConversationSearchVC(
                threadId: self.viewModel.threadId,
                threadVariant: self.viewModel.threadVariant,
                focusedInteractionId: nil
            ))
            break
        case .burnAfterReading :
            self.push(SessionTableViewController(
                viewModel: ThreadDisappearingMessagesViewModel(
                    threadId: self.viewModel.threadId,
                    config: self.disappearingMessagesConfig!
                )))
            break
        case .notication :
            self.push(SessionTableViewController(
                viewModel: NotificationSoundViewModel(threadId: self.viewModel.threadId)
            ))
            break
        case .mute :
            dependencies.storage.writeAsync { db in
                let currentValue: TimeInterval? = try SessionThread
                    .filter(id: self.viewModel.threadId)
                    .select(.mutedUntilTimestamp)
                    .asRequest(of: TimeInterval.self)
                    .fetchOne(db)
                
                try SessionThread
                    .filter(id: self.viewModel.threadId)
                    .updateAll(
                        db,
                        SessionThread.Columns.mutedUntilTimestamp.set(
                            to: (currentValue == nil ?
                                 Date.distantFuture.timeIntervalSince1970 :
                                    nil
                                )
                        )
                    )
            }
            break
        case .shield :
            let vc = ConfirmationModal(info: ConfirmationModal.Info(
                title: {
                    guard model.maybeThreadViewModel?.threadIsBlocked == true else {
                        return String(
                            format: "BLOCK_LIST_BLOCK_USER_TITLE_FORMAT".localized(),
                            model.maybeThreadViewModel?.displayName ?? ""
                        )
                    }
                    
                    return String(
                        format: "BLOCK_LIST_UNBLOCK_TITLE_FORMAT".localized(),
                        model.maybeThreadViewModel?.displayName ?? ""
                    )
                }(),
                body: (model.maybeThreadViewModel?.threadIsBlocked == true ? .none :
                    .text("BLOCK_USER_BEHAVIOR_EXPLANATION".localized())
                ),
                confirmTitle: (model.maybeThreadViewModel?.threadIsBlocked == true ?
                    "BLOCK_LIST_UNBLOCK_BUTTON".localized() :
                    "BLOCK_LIST_BLOCK_BUTTON".localized()
                ),
                confirmAccessibilityLabel: "Confirm block",
                confirmStyle: .danger,
                cancelStyle: .alert_text,
                onConfirm: { _ in
                    let isBlocked: Bool = (model.maybeThreadViewModel?.threadIsBlocked == true)
                    self.updateBlockedState(
                        from: isBlocked,
                        isBlocked: !isBlocked,
                        threadId: self.viewModel.threadId,
                        displayName: model.maybeThreadViewModel?.displayName ?? ""
                    )
                }
            ))
            self.present(vc, animated: true)
            break
        default:break
            
        
        }
    }
}

extension EMChatSettingPage{
    private func updateBlockedState(
        from oldBlockedState: Bool,
        isBlocked: Bool,
        threadId: String,
        displayName: String
    ) {
        guard oldBlockedState != isBlocked else { return }
        
        dependencies.storage.writeAsync(
            updates: { db in
                try Contact
                    .fetchOrCreate(db, id: threadId)
                    .with(isBlocked: .updateTo(isBlocked))
                    .save(db)
            },
            completion: { [weak self] db, _ in
                try MessageSender.syncConfiguration(db, forceSyncNow: true).retainUntilComplete()
                
                DispatchQueue.main.async {
                    let modal: ConfirmationModal = ConfirmationModal(
                        info: ConfirmationModal.Info(
                            title: (oldBlockedState == false ?
                                "BLOCK_LIST_VIEW_BLOCKED_ALERT_TITLE".localized() :
                                String(
                                    format: "BLOCK_LIST_VIEW_UNBLOCKED_ALERT_TITLE_FORMAT".localized(),
                                    displayName
                                )
                            ),
                            body: (oldBlockedState == true ? .none : .text(
                                String(
                                    format: "BLOCK_LIST_VIEW_BLOCKED_ALERT_MESSAGE_FORMAT".localized(),
                                    displayName
                                )
                            )),
                            accessibilityLabel: oldBlockedState == false ? "User blocked" : "Confirm unblock",
                            accessibilityId: "Test_name",
                            cancelTitle: "BUTTON_OK".localized(),
                            cancelAccessibilityLabel: "OK_BUTTON",
                            cancelStyle: .alert_text
                        )
                    )
                    self?.present(modal, animated: true)
                }
            }
        )
    }
    
    private func addUsersToOpenGoup(threadViewModel: SessionThreadViewModel?, selectedUsers: Set<String>) {
        guard let threadViewModel = threadViewModel else{
            return
        }
        guard
            let name: String = threadViewModel.openGroupName,
            let server: String = threadViewModel.openGroupServer,
            let roomToken: String = threadViewModel.openGroupRoomToken,
            let publicKey: String = threadViewModel.openGroupPublicKey
        else { return }
        
        dependencies.storage.writeAsync { db in
            let urlString: String = OpenGroup.urlFor(
                server: server,
                roomToken: roomToken,
                publicKey: publicKey
            )
            
            try selectedUsers.forEach { userId in
                let thread: SessionThread = try SessionThread.fetchOrCreate(db, id: userId, variant: .contact)
                
                try LinkPreview(
                    url: urlString,
                    variant: .openGroupInvitation,
                    title: name
                )
                .save(db)
                
                let interaction: Interaction = try Interaction(
                    threadId: thread.id,
                    authorId: userId,
                    variant: .standardOutgoing,
                    timestampMs: SnodeAPI.currentOffsetTimestampMs(),
                    expiresInSeconds: try? DisappearingMessagesConfiguration
                        .select(.durationSeconds)
                        .filter(id: userId)
                        .filter(DisappearingMessagesConfiguration.Columns.isEnabled == true)
                        .asRequest(of: TimeInterval.self)
                        .fetchOne(db),
                    linkPreviewUrl: urlString
                )
                .inserted(db)
                
                try MessageSender.send(
                    db,
                    interaction: interaction,
                    in: thread
                )
            }
        }
    }
}
