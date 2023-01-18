// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit
import SessionUtilitiesKit

extension MediaInfoVC {
    final class MediaInfoView: UIView {
        private static let cornerRadius: CGFloat = 8
        
        private let attachment: Attachment
        
        // MARK: - UI
        
        private lazy var fileIdLabel: UILabel = {
            let result: UILabel = UILabel()
            result.font = .systemFont(ofSize: Values.mediumFontSize)
            result.themeTextColor = .textPrimary
            
            return result
        }()
        
        private lazy var fileTypeLabel: UILabel = {
            let result: UILabel = UILabel()
            result.font = .systemFont(ofSize: Values.mediumFontSize)
            result.themeTextColor = .textPrimary
            
            return result
        }()
        
        private lazy var fileSizeLabel: UILabel = {
            let result: UILabel = UILabel()
            result.font = .systemFont(ofSize: Values.mediumFontSize)
            result.themeTextColor = .textPrimary
            
            return result
        }()
        
        private lazy var resolutionLabel: UILabel = {
            let result: UILabel = UILabel()
            result.font = .systemFont(ofSize: Values.mediumFontSize)
            result.themeTextColor = .textPrimary
            
            return result
        }()
        
        private lazy var durationLabel: UILabel = {
            let result: UILabel = UILabel()
            result.font = .systemFont(ofSize: Values.mediumFontSize)
            result.themeTextColor = .textPrimary
            
            return result
        }()
        
        // MARK: - Lifecycle
        
        init(attachment: Attachment) {
            self.attachment = attachment
            
            super.init(frame: CGRect.zero)
            self.accessibilityLabel = "Media info"
            setUpViewHierarchy()
        }

        override init(frame: CGRect) {
            preconditionFailure("Use init(attachment:) instead.")
        }

        required init?(coder: NSCoder) {
            preconditionFailure("Use init(attachment:) instead.")
        }

        private func setUpViewHierarchy() {
            let backgroundView: UIView = UIView()
            backgroundView.clipsToBounds = true
            backgroundView.themeBackgroundColor = .contextMenu_background
            backgroundView.layer.cornerRadius = Self.cornerRadius
            addSubview(backgroundView)
            backgroundView.pin(to: self)
            
            let container: UIView = UIView()
            container.set(.width, to: 245)
            
            // File ID
            let fileIdTitleLabel: UILabel = {
                let result = UILabel()
                result.font = .boldSystemFont(ofSize: Values.mediumFontSize)
                result.text = "ATTACHMENT_INFO_FILE_ID".localized() + ":"
                result.themeTextColor = .textPrimary
                
                return result
            }()
            fileIdLabel.text = attachment.serverId
            let fileIdContainerStackView: UIStackView = UIStackView(arrangedSubviews: [ fileIdTitleLabel, fileIdLabel ])
            fileIdContainerStackView.axis = .vertical
            container.addSubview(fileIdContainerStackView)
            fileIdContainerStackView.pin([ UIView.HorizontalEdge.leading, UIView.HorizontalEdge.trailing, UIView.VerticalEdge.top ], to: container)
            
            // File Type
            let fileTypeTitleLabel: UILabel = {
                let result = UILabel()
                result.font = .boldSystemFont(ofSize: Values.mediumFontSize)
                result.text = "ATTACHMENT_INFO_FILE_TYPE".localized() + ":"
                result.themeTextColor = .textPrimary
                
                return result
            }()
            fileTypeLabel.text = attachment.contentType
            let fileTypeContainerStackView: UIStackView = UIStackView(arrangedSubviews: [ fileTypeTitleLabel, fileTypeLabel ])
            fileTypeContainerStackView.axis = .vertical
            container.addSubview(fileTypeContainerStackView)
            fileTypeContainerStackView.pin(.leading, to: .leading, of: container)
            fileTypeContainerStackView.pin(.top, to: .bottom, of: fileIdContainerStackView, withInset: Values.mediumSpacing)
            
            // File Size
            let fileSizeTitleLabel: UILabel = {
                let result = UILabel()
                result.font = .boldSystemFont(ofSize: Values.mediumFontSize)
                result.text = "ATTACHMENT_INFO_FILE_SIZE".localized() + ":"
                result.themeTextColor = .textPrimary
                
                return result
            }()
            fileSizeLabel.text = OWSFormat.formatFileSize(attachment.byteCount)
            let fileSizeContainerStackView: UIStackView = UIStackView(arrangedSubviews: [ fileSizeTitleLabel, fileSizeLabel ])
            fileSizeContainerStackView.axis = .vertical
            container.addSubview(fileSizeContainerStackView)
            fileSizeContainerStackView.pin(.trailing, to: .trailing, of: container)
            fileSizeContainerStackView.pin(.top, to: .bottom, of: fileIdContainerStackView, withInset: Values.mediumSpacing)
            fileSizeContainerStackView.set(.width, to: 90)
            
            // Resolution
            let resolutionTitleLabel: UILabel = {
                let result = UILabel()
                result.font = .boldSystemFont(ofSize: Values.mediumFontSize)
                result.text = "ATTACHMENT_INFO_RESOLUTION".localized() + ":"
                result.themeTextColor = .textPrimary
                
                return result
            }()
            resolutionLabel.text = {
                guard let width = attachment.width, let height = attachment.height else { return "N/A" }
                return "\(width)×\(height)"
            }()
            let resolutionContainerStackView: UIStackView = UIStackView(arrangedSubviews: [ resolutionTitleLabel, resolutionLabel ])
            resolutionContainerStackView.axis = .vertical
            container.addSubview(resolutionContainerStackView)
            resolutionContainerStackView.pin(.leading, to: .leading, of: container)
            resolutionContainerStackView.pin(.top, to: .bottom, of: fileTypeContainerStackView, withInset: Values.mediumSpacing)
            
            // File Size
            let durationTitleLabel: UILabel = {
                let result = UILabel()
                result.font = .boldSystemFont(ofSize: Values.mediumFontSize)
                result.text = "ATTACHMENT_INFO_DURATION".localized() + ":"
                result.themeTextColor = .textPrimary
                
                return result
            }()
            durationLabel.text = {
                guard let duration = attachment.duration else { return "N/A" }
                return "\(duration)"
            }()
            let durationContainerStackView: UIStackView = UIStackView(arrangedSubviews: [ durationTitleLabel, durationLabel ])
            durationContainerStackView.axis = .vertical
            durationContainerStackView.pin(.trailing, to: .trailing, of: container)
            durationContainerStackView.pin(.top, to: .bottom, of: fileSizeContainerStackView, withInset: Values.mediumSpacing)
            durationContainerStackView.set(.width, to: 90)
            
            addSubview(container)
            container.pin(to: self, withInset: Values.mediumSpacing)
        }
    }
}
