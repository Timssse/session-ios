// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit
import SessionUtilitiesKit

final class MediaInfoVC: BaseVC {
    
    private let attachments: [Attachment]
    
    // MARK: - UI
    
    private lazy var fullScreenButton: UIButton = {
        let result: UIButton = UIButton(type: .custom)
        
        return result
    }()
    
    
    
    // MARK: - Initialization
    
    init(attachments: [Attachment]) {
        self.attachments = attachments
        super.init(nibName: nil, bundle: nil)
    }

    override init(nibName: String?, bundle: Bundle?) {
        preconditionFailure("Use init(attachments:) instead.")
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Use init(attachments:) instead.")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
