// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit
import SessionUtilitiesKit
import SignalUtilitiesKit

final class RestoreVC: BaseVC {
    private var spacer1HeightConstraint: NSLayoutConstraint!
    private var spacer2HeightConstraint: NSLayoutConstraint!
    private var spacer3HeightConstraint: NSLayoutConstraint!
    private var restoreButtonBottomOffsetConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Components
    
    private lazy var mnemonicTextView: TextView = {
        let result = TextView(placeholder: "vc_restore_seed_text_field_hint".localized())
        result.autocapitalizationType = .none
        result.themeBorderColor = .textPrimary
        result.accessibilityLabel = "Recovery phrase text view"
        
        return result
    }()
    
    private lazy var legalLabel: UILabel = {
        let result = UILabel()
        result.font = .systemFont(ofSize: Values.verySmallFontSize)
        let text = "By using this service, you agree to our Terms of Service, End User License Agreement (EULA) and Privacy Policy"
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: Values.verySmallFontSize)
            ]
        )
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: Values.verySmallFontSize), range: (text as NSString).range(of: "Terms of Service"))
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: Values.verySmallFontSize), range: (text as NSString).range(of: "End User License Agreement (EULA)"))
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: Values.verySmallFontSize), range: (text as NSString).range(of: "Privacy Policy"))
        result.themeTextColor = .textPrimary
        result.attributedText = attributedText
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 0
        
        return result
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up title label
        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: Values.veryLargeFontSize)
        titleLabel.text = "vc_restore_title".localized()
        titleLabel.themeTextColor = .textPrimary
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        
        // Set up explanation label
        let explanationLabel = UILabel()
        explanationLabel.font = .systemFont(ofSize: Values.smallFontSize)
        explanationLabel.text = "vc_restore_explanation".localized()
        explanationLabel.themeTextColor = .textPrimary
        explanationLabel.lineBreakMode = .byWordWrapping
        explanationLabel.numberOfLines = 0
        
        // Set up legal label
        legalLabel.isUserInteractionEnabled = true
        let legalLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLegalLabelTapped))
        legalLabel.addGestureRecognizer(legalLabelTapGestureRecognizer)
        
        // Set up spacers
        let topSpacer = UIView.vStretchingSpacer()
        let spacer1 = UIView()
        spacer1HeightConstraint = spacer1.set(.height, to: Values.veryLargeSpacing)
        let spacer2 = UIView()
        spacer2HeightConstraint = spacer2.set(.height, to: Values.veryLargeSpacing)
        let spacer3 = UIView()
        spacer3HeightConstraint = spacer3.set(.height, to: Values.veryLargeSpacing)
        let bottomSpacer = UIView.vStretchingSpacer()
        let restoreButtonBottomOffsetSpacer = UIView()
        restoreButtonBottomOffsetConstraint = restoreButtonBottomOffsetSpacer.set(.height, to: Values.onboardingButtonBottomOffset)
        
        // Set up restore button
        let restoreButton = UIButton(title: "continue_2".localized(),font: UIFont.Medium(size: 13),color: .white,backgroundColor: .messageBubble_outgoingBackground)
        restoreButton.dealLayer(corner: 14.w)
        restoreButton.setTitle("continue_2".localized(), for: UIControl.State.normal)
        restoreButton.addTarget(self, action: #selector(restore), for: UIControl.Event.touchUpInside)
        restoreButton.set(.height,to: 52.w)
        // Set up restore button container
        let restoreButtonContainer = UIView(wrapping: restoreButton, withInsets: UIEdgeInsets(top: 0, leading: 24.w, bottom: 0, trailing: 24.w), shouldAdaptForIPadWithWidth: Values.iPadButtonWidth)
        
        
        
        // Set up top stack view
        let topStackView = UIStackView(arrangedSubviews: [ titleLabel, spacer1, explanationLabel, spacer2, mnemonicTextView, spacer3, legalLabel ])
        topStackView.axis = .vertical
        topStackView.alignment = .fill
        
        // Set up top stack view container
        let topStackViewContainer = UIView()
        topStackViewContainer.addSubview(topStackView)
        topStackView.pin(.leading, to: .leading, of: topStackViewContainer, withInset: Values.veryLargeSpacing)
        topStackView.pin(.top, to: .top, of: topStackViewContainer)
        topStackViewContainer.pin(.trailing, to: .trailing, of: topStackView, withInset: Values.veryLargeSpacing)
        topStackViewContainer.pin(.bottom, to: .bottom, of: topStackView)
        
        // Set up main stack view
        let mainStackView = UIStackView(arrangedSubviews: [ topSpacer, topStackViewContainer, bottomSpacer, restoreButtonContainer, restoreButtonBottomOffsetSpacer ])
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        
        view.addSubview(mainStackView)
        mainStackView.pin(.leading, to: .leading, of: view)
        mainStackView.pin(.top, to: .top, of: view)
        mainStackView.pin(.trailing, to: .trailing, of: view)
        bottomConstraint = mainStackView.pin(.bottom, to: .bottom, of: view)
        topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor, multiplier: 1).isActive = true
        
        let logo = UIImageView(image: UIImage(named: "icon_create_logo"))
        self.view.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(topStackViewContainer.snp.top).offset(-5.w)
        }
        
        // Dismiss keyboard on tap
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // Listen to keyboard notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillChangeFrameNotification(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // On small screens we hide the legal label when the keyboard is up, but it's important that the user sees it so
        // in those instances we don't make the keyboard come up automatically
        mnemonicTextView.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: General
    @objc private func dismissKeyboard() {
        mnemonicTextView.resignFirstResponder()
    }
    
    // MARK: Updating
    @objc private func handleKeyboardWillChangeFrameNotification(_ notification: Notification) {
        guard let newHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else { return }
        
        bottomConstraint.constant = -newHeight // Negative due to how the constraint is set up
        restoreButtonBottomOffsetConstraint.constant = isIPhone6OrSmaller ? Values.smallSpacing : Values.largeSpacing
        spacer1HeightConstraint.constant = isIPhone6OrSmaller ? Values.smallSpacing : Values.mediumSpacing
        spacer2HeightConstraint.constant = isIPhone6OrSmaller ? Values.smallSpacing : Values.mediumSpacing
        spacer3HeightConstraint.constant = isIPhone6OrSmaller ? Values.smallSpacing : Values.mediumSpacing
        
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleKeyboardWillHideNotification(_ notification: Notification) {
        bottomConstraint.constant = 0
        restoreButtonBottomOffsetConstraint.constant = Values.onboardingButtonBottomOffset
        spacer1HeightConstraint.constant = Values.veryLargeSpacing
        spacer2HeightConstraint.constant = Values.veryLargeSpacing
        spacer3HeightConstraint.constant = Values.veryLargeSpacing
        
       
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Interaction
    
    @objc private func restore() {
        func showError(title: String, message: String = "") {
            let modal: ConfirmationModal = ConfirmationModal(
                info: ConfirmationModal.Info(
                    title: title,
                    body: .text(message),
                    cancelTitle: "BUTTON_OK".localized(),
                    cancelStyle: .alert_text
                )
            )
            present(modal, animated: true)
        }
        let mnemonic = mnemonicTextView.text!.lowercased()
        do {
            let hexEncodedSeed = try Mnemonic.decode(mnemonic: mnemonic)
            let seed = Data(hex: hexEncodedSeed)
            let (ed25519KeyPair, x25519KeyPair) = try Identity.generate(from: seed)
            Onboarding.Flow.recover.preregister(with: seed, ed25519KeyPair: ed25519KeyPair, x25519KeyPair: x25519KeyPair)
            mnemonicTextView.resignFirstResponder()
            
            Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
                let displayNameVC = DisplayNameVC()
                displayNameVC.seed = seed
                displayNameVC.ed25519KeyPair = ed25519KeyPair
                displayNameVC.x25519KeyPair = x25519KeyPair
                self.navigationController!.pushViewController(displayNameVC, animated: true)
            }
        } catch let error {
            let error = error as? Mnemonic.DecodingError ?? Mnemonic.DecodingError.generic
            showError(title: error.errorDescription!)
        }
    }
    
    @objc private func handleLegalLabelTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let urlAsString: String?
        let tosRange = (legalLabel.text! as NSString).range(of: "Terms of Service")
        let eulaRange = (legalLabel.text! as NSString).range(of: "End User License Agreement (EULA)")
        let ppRange = (legalLabel.text! as NSString).range(of: "Privacy Policy")
        let touchInLegalLabelCoordinates = tapGestureRecognizer.location(in: legalLabel)
        let characterIndex = legalLabel.characterIndex(for: touchInLegalLabelCoordinates)
        
        if tosRange.contains(characterIndex) {
            urlAsString = "https://getsession.org/terms-of-service/"
        } else if eulaRange.contains(characterIndex) {
            urlAsString = "https://getsession.org/terms-of-service/#eula"
        } else if ppRange.contains(characterIndex) {
            urlAsString = "https://getsession.org/privacy-policy/"
        } else {
            urlAsString = nil
        }
        
        if let urlAsString = urlAsString {
            let url = URL(string: urlAsString)!
            UIApplication.shared.open(url)
        }
    }
}
