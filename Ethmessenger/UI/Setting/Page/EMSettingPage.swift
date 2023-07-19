// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionMessagingKit
import GRDB
import DifferenceKit
import Combine
import SessionUIKit
import SessionUtilitiesKit
class EMSettingPage: BaseVC,ThemedNavigation {
    typealias SectionModel = ArraySection<SettingsViewModel.Section, SessionCell.Info<SettingsViewModel.Item>>
    typealias ObservableData = AnyPublisher<[SectionModel], Error>
    private var dataChangeCancellable: AnyCancellable?
    
    var profile : Profile?
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavBarButtons()
        
    }
    
    lazy var _observableSettingsData : ObservableData = ValueObservation.trackingConstantRegion {[weak self] db -> [SectionModel] in
        self?.profile = Profile.fetchOrCreateCurrentUser(db)
        return []
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
        tableView.register(EMSettingUserInfoCell.self, forCellReuseIdentifier: "EMSettingUserInfoCell")
        tableView.register(EMSettingCell.self, forCellReuseIdentifier: "EMSettingCell")
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

    
    private func updateNavBarButtons() {
        // Profile picture view
        self.title = ""
        
        let labTitle = UILabel(font: UIFont.Bold(size: 20),textColor: .textPrimary,text: "vc_settings_title".localized())
        labTitle.frame = CGRect(x: 0, y: 0, width: 200.w, height: 30.w)
        
        // Left bar button item
        let leftBarButtonItem = UIBarButtonItem(customView: labTitle)
        leftBarButtonItem.isAccessibilityElement = true
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        // Right bar button item - search button
        let qrcodeItem = UIBarButtonItem(image: UIImage(named: "icon_setting_qrcode"), style: .done, target: self, action: #selector(onclickQrcode))
        qrcodeItem.themeTintColor = .textPrimary
        navigationItem.rightBarButtonItem = qrcodeItem
    }
    
    lazy var dataArr : [EMSettingSectionModel] = {
        return [
            EMSettingSectionType.createSection(.userInfo,profile: self.profile),
            EMSettingSectionType.createSection(.settings),
            EMSettingSectionType.createSection(.help)
        ]
    }()
    
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
}

extension EMSettingPage: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "EMSettingUserInfoCell", for: indexPath) as! EMSettingUserInfoCell
            cell.model = data.cells[indexPath.row].userInfo
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
        if section == 1 {
            return 40.w
        }
        return 25.w
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: section == 0 ? 0 : section == 1 ? 40.w : 25.w))
        view.themeBackgroundColor = .navBack
        let bgView = UIView(.conversationButton_background)
        bgView.frame = view.bounds
        view.addSubview(bgView)
        
        if section == 1{
            bgView.dealCorner(type: .topLeftRight, corner: 20.w)
        }
        
        if section != 0{
            let lab = UILabel(font: UIFont.Regular(size: 13),textColor: .textGary,text: section == 1 ? "vc_settings_title".localized() : "HELP_TITLE".localized())
            bgView.addSubview(lab)
            lab.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(25.w)
                make.bottom.equalToSuperview()
            }
        }
        
        
        return view
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.dataArr[indexPath.section]
        switch data.cells[indexPath.row].type{
        case .path :
            self.push(PathVC())
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
        case .appearance :
            self.push(AppearanceViewController())
            break
        case .invite :
//            let invitation: String = "Hey, I've been using Session to chat with complete privacy and security. Come join me! Download it at https://getsession.org/. My Session ID is \(profile.id) !"
//
//            self?.transitionToScreen(
//                UIActivityViewController(
//                    activityItems: [ invitation ],
//                    applicationActivities: nil
//                ),
//                transitionType: .present
//            )
            break
        case .recovery :
            self.present(SeedModal(), animated: true)
            break
        case .language :
            
            break
        case .help :
            self.push(SessionTableViewController(viewModel: HelpViewModel()))
            break
        case .clean :
            self.present(NukeDataModal(), animated: true)
            break
        default:break
            
        
        }
    }
}
