// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit.UIColor

internal enum Theme_ClassicLight: ThemeColors {
    static let theme: [ThemeValue: UIColor] = [
        // General
        .white: .white,
        .black: .black,
        .clear: .clear,
        .primary: .primary,
        .defaultPrimary: Theme.PrimaryColor.green.color,
        .warning: .warning,
        .danger: .dangerLight,
        .disabled: .disabledLight,
        .backgroundPrimary: .classicLight6,
        .backgroundSecondary: .classicLight5,
        .textPrimary: .classicLight0,
        .textSecondary: .classicLight1,
        .borderSeparator: .classicLight2,
        
        // Path
        .path_connected: .pathConnected,
        .path_connecting: .pathConnecting,
        .path_error: .pathError,
        .path_unknown: .classicLight4,
    
        // TextBox
        .textBox_background: .classicLight6,
        .textBox_border: .classicLight2,
    
        // MessageBubble
        .messageBubble_outgoingBackground: .messageBubble_outgoingBackground,
        .messageBubble_incomingBackground: .messageBubble_incomingBackgroundLight,
        .messageBubble_outgoingText: .classicLight0,
        .messageBubble_incomingText: .classicLight0,
        .messageBubble_overlay: .black_06,
        .messageBubble_deliveryStatus: .classicLight1,

        // MenuButton
        .menuButton_background: .primary,
        .menuButton_icon: .classicLight6,
        .menuButton_outerShadow: .classicLight0,
        .menuButton_innerShadow: .classicLight6,
        
        // RadioButton
        .radioButton_selectedBackground: .primary,
        .radioButton_unselectedBackground: .clear,
        .radioButton_selectedBorder: .classicLight0,
        .radioButton_unselectedBorder: .classicLight0,
        .radioButton_disabledSelectedBackground: .disabledLight,
        .radioButton_disabledUnselectedBackground: .clear,
        .radioButton_disabledBorder: .disabledLight,
        
        // OutlineButton
        .sessionButton_text: .classicLight0,
        .sessionButton_background: .clear,
        .sessionButton_highlight: .classicLight0.withAlphaComponent(0.1),
        .sessionButton_border: .classicLight0,
        .sessionButton_filledText: .classicLight6,
        .sessionButton_filledBackground: .classicLight0,
        .sessionButton_filledHighlight: .classicLight1,
        .sessionButton_destructiveText: .dangerLight,
        .sessionButton_destructiveBackground: .clear,
        .sessionButton_destructiveHighlight: .dangerLight.withAlphaComponent(0.3),
        .sessionButton_destructiveBorder: .dangerLight,
        
        // SolidButton
        .solidButton_background: .classicLight3,
        
        // Settings
        .settings_tabBackground: .classicLight5,
        
        // AppearanceButton
        .appearance_sectionBackground: .classicLight6,
        .appearance_buttonBackground: .classicLight6,
        
        // Alert
        .alert_text: .classicLight0,
        .alert_background: .classicLight6,
        .alert_buttonBackground: .classicLight6,
        
        // ConversationButton
        .conversationButton_background: .classicLight6,
        .conversationButton_unreadBackground: .classicLight6,
        .conversationButton_unreadStripBackground: .primary,
        .conversationButton_unreadBubbleBackground: .dangerLight,
        .conversationButton_unreadBubbleText: .classicDark6,
        .conversationButton_swipeDestructive: .dangerLight,
        .conversationButton_swipeSecondary: .classicLight1,
        .conversationButton_swipeTertiary: Theme.PrimaryColor.orange.color,
        
        // InputButton
        .inputButton_background: .classicLight4,
        
        // ContextMenu
        .contextMenu_background: .classicLight6,
        .contextMenu_highlight: .primary,
        .contextMenu_text: .classicLight0,
        .contextMenu_textHighlight: .classicLight0,
        
        // Call
        .callAccept_background: Theme.PrimaryColor.green.color,
        .callDecline_background: .dangerLight,
        
        // Reactions
        .reactions_contextBackground: .classicLight4,
        .reactions_contextMoreBackground: .classicLight6,
        
        // NewConversation
        .newConversation_background: .classicLight6,
        .line : .line,
        .borderLine : .borderLine,
        .textGary : .textGary,
        .navBack : .navBack,
        .chatBackgroundPrimary : .chatBackgroundPrimaryLight,
        .setting_icon_icon : .color_616569,
        .tab_select_bg : .white,
        .textGary1 : .color_C2C9D1,
        .communitTool : .color_BEBEBE,
        .textPlaceholder : .color_BEBEBE,
        .communitInput : .white,
        .iconColor : .color_616569,
        .forwardingBGColor : .chatBackgroundPrimaryLight,
        .user_session_bg : .color_FFFFFF_A30,
        .color_91979D : .color_91979D,
        .color_616569 : .color_616569,
        .user_communit_bg : .color_FFFFFF_A80,
        .emptyContent : .color_DDE3EF,
        .alertTextColor : .color_616569,
        .wallet_bg : .white,
        .password_border_color : .color_F2F2F2,
        .forget_textView_bg : .color_FAFAFA,
        .heart : .color_F91880,
        .FF823B : .color_FF823B,
        .Color_91979D_616569 : .color_91979D,
        .Color_F9FAFF_272727 : .color_F9FAFF,
        .Color_white_616569 : .white
    ]
}
