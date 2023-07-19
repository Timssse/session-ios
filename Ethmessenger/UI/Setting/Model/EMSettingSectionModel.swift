// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionMessagingKit

enum EMSettingSectionType : String{
    case userInfo
    case groupInfo
    case settings
    case help
    case chatSettings
    case privateGroupSettings
    case openGroupSettings
    static func createSection(_ type : EMSettingSectionType,
                              profile : Profile? = nil,
                              disappearingMessagesConfig : DisappearingMessagesConfiguration? = nil,
                              notificationSound : Preferences.Sound? = nil,
                              maybeThreadViewModel: SessionThreadViewModel? = nil) -> EMSettingSectionModel{
        switch type{
        case userInfo :
            return EMSettingSectionModel.init(cells: [EMSettingCellType.createCell(.userInfo,profile: profile)], type: .userInfo)
        case groupInfo :
            return EMSettingSectionModel.init(cells: [EMSettingCellType.createCell(.groupInfo,profile: profile)], type: .groupInfo)
        case settings :
            return EMSettingSectionModel.init(cells: [EMSettingCellType.createCell(.path),
                                                      EMSettingCellType.createCell(.privacy),
                                                      EMSettingCellType.createCell(.notification),
                                                      EMSettingCellType.createCell(.conversations),
                                                      EMSettingCellType.createCell(.message),
                                                      EMSettingCellType.createCell(.appearance),
                                                      EMSettingCellType.createCell(.recovery),
                                                      EMSettingCellType.createCell(.invite),
                                                      EMSettingCellType.createCell(.language)], type: .settings)
        case help :
            return EMSettingSectionModel.init(cells: [EMSettingCellType.createCell(.help),EMSettingCellType.createCell(.clean)], type: .help)
        case chatSettings :
            return EMSettingSectionModel.init(cells: [EMSettingCellType.createCell(.photo),
                                                      EMSettingCellType.createCell(.search),
                                                      EMSettingCellType.createCell(.burnAfterReading,disappearingMessagesConfig: disappearingMessagesConfig),
                                                      EMSettingCellType.createCell(.notication,notificationSound: notificationSound),
                                                      EMSettingCellType.createCell(.mute,maybeThreadViewModel: maybeThreadViewModel),
                                                      EMSettingCellType.createCell(.shield,maybeThreadViewModel: maybeThreadViewModel)], type: .chatSettings)
        case privateGroupSettings :
            return EMSettingSectionModel.init(cells: [EMSettingCellType.createCell(.photo),
                                                      EMSettingCellType.createCell(.search),
                                                      EMSettingCellType.createCell(.burnAfterReading,disappearingMessagesConfig: disappearingMessagesConfig),
                                                      EMSettingCellType.createCell(.editGroup),
                                                      EMSettingCellType.createCell(.leaveGroup),
                                                      EMSettingCellType.createCell(.notication,notificationSound: notificationSound),
                                                      EMSettingCellType.createCell(.mute,maybeThreadViewModel: maybeThreadViewModel),
                                                      EMSettingCellType.createCell(.notifyMentionsOnly,maybeThreadViewModel: maybeThreadViewModel)], type: .privateGroupSettings)
        case openGroupSettings :
            return EMSettingSectionModel.init(cells: [EMSettingCellType.createCell(.copyGroupUrl),
                                                      EMSettingCellType.createCell(.photo),
                                                      EMSettingCellType.createCell(.search),
                                                      EMSettingCellType.createCell(.addMembers),
                                                      EMSettingCellType.createCell(.notication,notificationSound: notificationSound),
                                                      EMSettingCellType.createCell(.mute,maybeThreadViewModel: maybeThreadViewModel),
                                                      EMSettingCellType.createCell(.notifyMentionsOnly,maybeThreadViewModel: maybeThreadViewModel)], type: .privateGroupSettings)
        }
    }
}

enum EMSettingCellType : String{
    case userInfo
    case copyGroupUrl
    case groupInfo
    case path
    case privacy
    case notification
    case conversations
    case message
    case appearance
    case recovery
    case invite
    case language
    case help
    case clean
    case photo
    case search
    case burnAfterReading
    case editGroup
    case leaveGroup
    case notication
    case mute
    case shield
    case notifyMentionsOnly
    case addMembers
    
    static func createCell(_ type : EMSettingCellType,
                           profile : Profile? = nil,
                           disappearingMessagesConfig : DisappearingMessagesConfiguration? = nil,
                           notificationSound : Preferences.Sound? = nil,
                           maybeThreadViewModel: SessionThreadViewModel? = nil) -> EMSettingCellModel{
        switch type{
        case userInfo :
            return EMSettingCellModel(userInfo: profile,type: type)
        case groupInfo :
            return EMSettingCellModel(userInfo: profile,type: type)
        case path :
            return EMSettingCellModel(title: "vc_path_title".localized(),status: 1,type: type)
        case privacy :
            return EMSettingCellModel(title: "vc_settings_privacy_button_title".localized(),icon: UIImage(named: "icon_setting_privacy"),type: type)
        case notification :
            return EMSettingCellModel(title: "vc_settings_notifications_button_title".localized(),icon: UIImage(named: "icon_setting_notification"),type: type)
        case conversations :
            return EMSettingCellModel(title: "CONVERSATION_SETTINGS_TITLE".localized(),icon: UIImage(named: "icon_setting_conversations"),type: type)
        case message :
            return EMSettingCellModel(title: "MESSAGE_REQUESTS_TITLE".localized(),icon: UIImage(named: "icon_setting_message"),type: type)
        case appearance :
            return EMSettingCellModel(title: "APPEARANCE_TITLE".localized(),icon: UIImage(named: "icon_setting_appearance"),type: type)
        case recovery :
            return EMSettingCellModel(title: "vc_enter_recovery_phrase_title".localized(),icon: UIImage(named: "icon_setting_recovery"),type: type)
        case invite :
            return EMSettingCellModel(title: "vc_settings_invite_a_friend_button_title".localized(),icon: UIImage(named: "icon_setting_invite"),type: type)
        case language :
            return EMSettingCellModel(title: "LocalLanguage".localized(),type: type)
        case help :
            return EMSettingCellModel(title: "HELP_TITLE".localized(),icon: UIImage(named: "icon_setting_help"),type: type)
        case clean :
            return EMSettingCellModel(title: "vc_settings_clear_all_data_button_title".localized(),icon: UIImage(named: "icon_setting_cleanData"),type: type)
        case photo :
            return EMSettingCellModel(title: "MEDIA_DETAIL_VIEW_ALL_MEDIA_BUTTON".localized(),icon: UIImage(named: "icon_chats_photo"),type: type)
        case search :
            return EMSettingCellModel(title: "CONVERSATION_SETTINGS_SEARCH".localized(),icon: UIImage(named: "icon_chats_search"),type: type)
        case .burnAfterReading :
            return EMSettingCellModel(title: "DISAPPEARING_MESSAGES".localized(),icon: UIImage(named: "icon_chats_burnAfterRead"),disappearingMessagesConfig: disappearingMessagesConfig,type: type)
        case .notication :
            return EMSettingCellModel(title: "SETTINGS_ITEM_NOTIFICATION_SOUND".localized(),icon: UIImage(named: "icon_setting_notification"),notificationSound: notificationSound,type: type)
        case .mute :
            return EMSettingCellModel(title: "CONVERSATION_SETTINGS_MUTE_LABEL".localized(),icon: UIImage(named: "icon_chats_mute"),maybeThreadViewModel: maybeThreadViewModel,type: type)
        case .shield :
            return EMSettingCellModel(title: "CONVERSATION_SETTINGS_BLOCK_THIS_USER".localized(),icon: UIImage(named: "icon_chats_shield"),maybeThreadViewModel: maybeThreadViewModel,type: type)
        case .copyGroupUrl:
            return EMSettingCellModel(title: "COPY_GROUP_URL".localized(),icon: UIImage(named: "icon_chats_copyGroupUrl"),type: type)
        case .editGroup:
            return EMSettingCellModel(title: "EDIT_GROUP_ACTION".localized(),icon: UIImage(named: "icon_chats_editGroup"),type: type)
        case .leaveGroup:
            return EMSettingCellModel(title: "LEAVE_GROUP_ACTION".localized(),icon: UIImage(named: "icon_chats_leaveGroup"),type: type)
        case .notifyMentionsOnly:
            return EMSettingCellModel(title: "vc_conversation_settings_notify_for_mentions_only_title".localized(),icon: UIImage(named: "icon_chats_notifyMentionsOnly"),maybeThreadViewModel: maybeThreadViewModel,type: type)
        case .addMembers:
            return EMSettingCellModel(title: "vc_conversation_settings_invite_button_title".localized(),icon: UIImage(named: "icon_chats_addMembers"),type: type)
        }
        
    }
    
}


struct EMSettingSectionModel : Equatable{
    static func == (lhs: EMSettingSectionModel, rhs: EMSettingSectionModel) -> Bool {
        return lhs.type == rhs.type && lhs.cells == rhs.cells
    }
    
    var cells : [EMSettingCellModel]
    var type : EMSettingSectionType = .userInfo
    init(cells: [EMSettingCellModel],type : EMSettingSectionType) {
        self.cells = cells
        self.type = type
    }
}

class EMSettingCellModel : Equatable{
    var title : String?
    var icon : UIImage?
    var type : EMSettingCellType = .path
    var status : Int = 0
    var content : String?
    var userInfo : Profile?
    var notificationSound : Preferences.Sound?
    var disappearingMessagesConfig : DisappearingMessagesConfiguration?
    var maybeThreadViewModel: SessionThreadViewModel?
    convenience init(title: String? = nil, icon: UIImage? = nil, status: Int = 0, userInfo: Profile? = nil,content : String? = nil,disappearingMessagesConfig : DisappearingMessagesConfiguration? = nil,notificationSound : Preferences.Sound? = nil,maybeThreadViewModel: SessionThreadViewModel? = nil,type : EMSettingCellType) {
        self.init()
        self.title = title
        self.icon = icon
        self.status = status
        self.type = type
        self.userInfo = userInfo
        self.content = content
        self.disappearingMessagesConfig = disappearingMessagesConfig
        self.notificationSound = notificationSound
        self.maybeThreadViewModel = maybeThreadViewModel
    }
    
    static func == (lhs: EMSettingCellModel, rhs: EMSettingCellModel) -> Bool {
        return (lhs.title == rhs.title &&
                lhs.icon == rhs.icon &&
                lhs.status == rhs.status &&
                lhs.userInfo == rhs.userInfo &&
                lhs.disappearingMessagesConfig == rhs.disappearingMessagesConfig &&
                lhs.notificationSound == rhs.notificationSound &&
                lhs.maybeThreadViewModel == rhs.maybeThreadViewModel)
    }
}

