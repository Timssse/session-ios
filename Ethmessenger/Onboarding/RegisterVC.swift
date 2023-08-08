// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import Sodium
import WalletCore
import Curve25519Kit
import SessionUIKit
import SignalUtilitiesKit

final class RegisterVC : BaseVC {
    private var seed: Data! { didSet { updateKeyPair() } }
    private var ed25519KeyPair: Sign.KeyPair!
    private var x25519KeyPair: ECKeyPair! { didSet { updatePublicKeyLabel() } }
    
    // MARK: - Components
    
    private lazy var publicKeyLabel: UILabel = {
        let result = UILabel()
        result.font = Fonts.spaceMono(ofSize: 20)
        result.themeTextColor = .textPrimary
        result.accessibilityLabel = "Session ID"
        result.isAccessibilityElement = true
        result.lineBreakMode = .byCharWrapping
        result.numberOfLines = 0
        
        return result
    }()
    
    private lazy var copyPublicKeyButton: UIButton = {
        let result = UIButton(title: "copy".localized(),font: UIFont.Medium(size: 13),color: .textPrimary)
        result.dealBorderLayer(corner: 14.w, bordercolor: .textPrimary, borderwidth: 1)
        result.addTarget(self, action: #selector(copyPublicKey), for: .touchUpInside)
        return result
    }()
    
    
    private lazy var legalLabel: UILabel = {
        let result = UILabel()
        result.font = .systemFont(ofSize: Values.verySmallFontSize)
        result.themeTextColor = .textPrimary
        let text = "By using this service, you agree to our Terms of Service, End User License Agreement (EULA) and Privacy Policy"
        let attributedText = NSMutableAttributedString(string: text, attributes: [ .font : UIFont.systemFont(ofSize: Values.verySmallFontSize) ])
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: Values.verySmallFontSize), range: (text as NSString).range(of: "Terms of Service"))
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: Values.verySmallFontSize), range: (text as NSString).range(of: "End User License Agreement (EULA)"))
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: Values.verySmallFontSize), range: (text as NSString).range(of: "Privacy Policy"))
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
        titleLabel.text = "vc_register_title".localized()
        titleLabel.themeTextColor = .textPrimary
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        
        // Set up explanation label
        let explanationLabel = UILabel()
        explanationLabel.font = .systemFont(ofSize: Values.smallFontSize)
        explanationLabel.text = "vc_register_explanation".localized()
        explanationLabel.themeTextColor = .textPrimary
        explanationLabel.lineBreakMode = .byWordWrapping
        explanationLabel.numberOfLines = 0
        
        // Set up public key label container
        let publicKeyLabelContainer = UIView()
        publicKeyLabelContainer.addSubview(publicKeyLabel)
        publicKeyLabel.pin(to: publicKeyLabelContainer, withInset: Values.mediumSpacing)
        publicKeyLabelContainer.layer.cornerRadius = 14.w
        publicKeyLabelContainer.layer.borderWidth = 1
        publicKeyLabelContainer.themeBorderColor = .textPrimary
        
        // Set up spacers
        let topSpacer = UIView.vStretchingSpacer()
        let bottomSpacer = UIView.vStretchingSpacer()
        
        // Set up register button
        let registerButton = UIButton(title: "continue_2".localized(),font: UIFont.Medium(size: 13),color: .white,backgroundColor: .messageBubble_outgoingBackground)
        registerButton.dealLayer(corner: 14.w)
        registerButton.addTarget(self, action: #selector(register), for: UIControl.Event.touchUpInside)
        registerButton.set(.width, to: 124.w)
        registerButton.set(.height, to: 56.w)
        copyPublicKeyButton.set(.width, to: 124.w)
        copyPublicKeyButton.set(.height, to: 56.w)
        // Set up button stack view
        let buttonStackView = UIStackView(arrangedSubviews: [ copyPublicKeyButton,registerButton ])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.spacing = 40.w
//        if UIDevice.current.isIPad {
//            registerButton.set(.width, to: Values.iPadButtonWidth)
//            copyPublicKeyButton.set(.width, to: Values.iPadButtonWidth)
//            buttonStackView.alignment = .center
//        }
        
        // Set up button stack view container
        let buttonStackViewContainer = UIView()
        buttonStackViewContainer.addSubview(buttonStackView)
        buttonStackView.pin(.leading, to: .leading, of: buttonStackViewContainer, withInset: 24.w)
        buttonStackView.pin(.top, to: .top, of: buttonStackViewContainer)
        buttonStackViewContainer.pin(.trailing, to: .trailing, of: buttonStackView, withInset: 24.w)
        buttonStackViewContainer.pin(.bottom, to: .bottom, of: buttonStackView)
        
        // Set up legal label
        legalLabel.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLegalLabelTapped))
        legalLabel.addGestureRecognizer(tapGestureRecognizer)
        
        // Set up legal label container
        let legalLabelContainer = UIView()
        legalLabelContainer.set(.height, to: Values.onboardingButtonBottomOffset)
        
        // Set up top stack view
        let topStackView = UIStackView(arrangedSubviews: [titleLabel, explanationLabel, publicKeyLabelContainer ])
        topStackView.axis = .vertical
        topStackView.spacing = Values.veryLargeSpacing
//        topStackView.alignment = .fill
        
        
        // Set up top stack view container
        let topStackViewContainer = UIView()
        topStackViewContainer.addSubview(topStackView)
        topStackView.pin(.leading, to: .leading, of: topStackViewContainer, withInset: Values.veryLargeSpacing)
        topStackView.pin(.top, to: .top, of: topStackViewContainer)
        topStackViewContainer.pin(.trailing, to: .trailing, of: topStackView, withInset: Values.veryLargeSpacing)
        topStackViewContainer.pin(.bottom, to: .bottom, of: topStackView)
        
        // Set up main stack view
        let mainStackView = UIStackView(arrangedSubviews: [ topSpacer, topStackViewContainer, bottomSpacer, buttonStackViewContainer, legalLabelContainer ])
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        view.addSubview(mainStackView)
        mainStackView.pin(to: view)
        topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor, multiplier: 1).isActive = true
        
        let logo = UIImageView(image: UIImage(named: "icon_create_logo"))
        self.view.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(topStackViewContainer.snp.top).offset(-5.w)
        }
        
        // Peform initial seed update
        updateSeed()
    }
    
    // MARK: General
    @objc private func enableCopyButton() {
        copyPublicKeyButton.isUserInteractionEnabled = true
        UIView.transition(with: copyPublicKeyButton, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.copyPublicKeyButton.setTitle("copy".localized(), for: .normal)
        }, completion: nil)
    }
    
    // MARK: Updating
    private func updateSeed() {
//        let mnemonic = WalletCore.cre
        let data = Data.randomBytes(length: 32)!
        seed = data
    }
    
    private func updateKeyPair() {
        (ed25519KeyPair, x25519KeyPair) = try! Identity.generate(from: seed)
    }
    
    private func updatePublicKeyLabel() {
        let hexEncodedPublicKey = x25519KeyPair.hexEncodedPublicKey
        publicKeyLabel.accessibilityLabel = hexEncodedPublicKey
        publicKeyLabel.accessibilityIdentifier = "Session ID"
        publicKeyLabel.isAccessibilityElement = true
        let characterCount = hexEncodedPublicKey.count
        var count = 0
        let limit = 32
        func animate() {
            let numberOfIndexesToShuffle = 32 - count
            let indexesToShuffle = (0..<characterCount).shuffled()[0..<numberOfIndexesToShuffle]
            var mangledHexEncodedPublicKey = hexEncodedPublicKey
            for index in indexesToShuffle {
                let startIndex = mangledHexEncodedPublicKey.index(mangledHexEncodedPublicKey.startIndex, offsetBy: index)
                let endIndex = mangledHexEncodedPublicKey.index(after: startIndex)
                mangledHexEncodedPublicKey.replaceSubrange(startIndex..<endIndex, with: "0123456789abcdef__".shuffled()[0..<1])
            }
            count += 1
            if count < limit {
                publicKeyLabel.text = mangledHexEncodedPublicKey
                Timer.scheduledTimer(withTimeInterval: 0.032, repeats: false) { _ in
                    animate()
                }
            } else {
                publicKeyLabel.text = hexEncodedPublicKey
            }
        }
        animate()
    }
    
    // MARK: Interaction
    @objc private func register() {
        
        let displayNameVC = DisplayNameVC()
        displayNameVC.seed = seed
        displayNameVC.ed25519KeyPair = ed25519KeyPair
        displayNameVC.x25519KeyPair = x25519KeyPair
        navigationController!.pushViewController(displayNameVC, animated: true)
    }
    
    @objc private func copyPublicKey() {
        UIPasteboard.general.string = x25519KeyPair.hexEncodedPublicKey
        copyPublicKeyButton.isUserInteractionEnabled = false
        copyPublicKeyButton.accessibilityLabel = "LocalCopySessionID".localized()
        copyPublicKeyButton.isAccessibilityElement = true
        UIView.transition(with: copyPublicKeyButton, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.copyPublicKeyButton.setTitle("copied".localized(), for: .normal)
        }, completion: nil)
        Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(enableCopyButton), userInfo: nil, repeats: false)
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
