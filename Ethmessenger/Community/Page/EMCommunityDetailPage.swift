// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunityDetailPage: EMRefreshController {
    private var model : EMCommunityHomeListEntity!
    init(model : EMCommunityHomeListEntity){
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrameNotification(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHideNotification(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        sendView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sendView.textView.resignFirstResponder()
        sendView.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sendView.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.maskView.isHidden = true
        UIUtil.getWindow()?.addSubview(sendView)
        sendView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.height.equalTo(50.w)
            make.bottom.equalToSuperview().offset(-safeBottomH)
        }
        self.refressh()
    }

    lazy var tableView : UITableView = {
        let tableView = EMTableView(delegate: self, dataSource: self, backgroundColor: .conversationButton_background)
        tableView.register(EMCommunitDetailHeadCell.self, forCellReuseIdentifier: "EMCommunitDetailHeadCell")
        tableView.register(EMCommunityCommentCell.self, forCellReuseIdentifier: "EMCommunityCommentCell")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 20.w))
        let footerView = UIView(.conversationButton_background)
        footerView.frame = CGRect(x: 0, y: 0, width: Screen_width, height: 100.w)
        tableView.tableFooterView = footerView
        setRefreshView(tableView)
        return tableView
    }()
    
    lazy var sendView : EMCommunitySendView = {
        let view = EMCommunitySendView(model:self.model)
        view.commentBlock = {[weak self] in
            self?.refressh()
        }
        return view
    }()
    
    lazy var maskView : EMMaskView = {
        let view = EMMaskView()
        view.clickBlock = { [weak self] in
            self?.sendView.textView.resignFirstResponder()
        }
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()
    
    
    
    
    lazy var commentArr : [EMCommunityCommentEntity] = []
}

extension EMCommunityDetailPage{
    override func refressh() {
        self.page = 1
        isLoadMore = false
        self.getData()
    }

    func getData(){
        Task{
            if let data = await EMCommunityController.detail(self.model.TwAddress){
                self.model = data
            }
            if self.model.CommentCount == 0{
                self.tableView.reloadData()
                self.endRefreshing()
                return
            }
            getComment()
        }
    }
    
    func getComment(){
        if isLoadMore == true{
            return
        }
        isLoadMore = true
        Task{
            let data = await EMCommunityController.commentList(twAddress: self.model.TwAddress, page: self.page)
            isLoadMore = data.count < 10
            if self.page == 1{
                self.commentArr.removeAll()
            }
            self.endRefreshing()
            self.page += 1
            self.commentArr += data
            self.tableView.reloadData()
            self.endRefreshing()
        }
    }
}

extension EMCommunityDetailPage{
    
    @objc func handleKeyboardWillChangeFrameNotification(_ notification: Notification) {
        let userInfo: [AnyHashable: Any] = (notification.userInfo ?? [:])
        let duration = ((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0)
        let curveValue: Int = ((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? Int(UIView.AnimationOptions.curveEaseInOut.rawValue))
        let options: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(curveValue << 16))
        let keyboardRect: CGRect = ((userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? CGRect.zero)
        let keyboardTop = (UIScreen.main.bounds.height - keyboardRect.minY)
        
        self.maskView.isHidden = false
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: { [weak self] in
                self?.sendView.snp.updateConstraints { make in
                    make.height.equalTo(156.w)
                    make.bottom.equalToSuperview().offset(-(keyboardTop) - 20.w)
                }
                self?.sendView.superview?.layoutIfNeeded()
                self?.sendView.layoutIfNeeded()
            },
            completion: nil
        )
    }

    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        let userInfo: [AnyHashable: Any] = (notification.userInfo ?? [:])
        let duration = ((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0)
        let curveValue: Int = ((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? Int(UIView.AnimationOptions.curveEaseInOut.rawValue))
        let options: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(curveValue << 16))

        self.maskView.isHidden = true
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: { [weak self] in
                self?.sendView.snp.updateConstraints { make in
                    make.height.equalTo(50.w)
                    make.bottom.equalToSuperview().offset(-safeBottomH)
                }
                self?.sendView.superview?.layoutIfNeeded()
                self?.sendView.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

extension EMCommunityDetailPage : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.commentArr.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.commentArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EMCommunitDetailHeadCell", for: indexPath) as! EMCommunitDetailHeadCell
            cell.model = self.model
            cell.toolView.likeBlock = {[weak self] in
                Task{
                    guard let model = self?.model else{
                        return
                    }
                    await EMCommunityController.like(model.TwAddress)
                    model.isTwLike = !model.isTwLike
                    model.LikeCount = model.isTwLike ? (model.LikeCount + 1) : (model.LikeCount > 0 ? model.LikeCount - 1 : 0)
                    self?.tableView.reloadData()
                }
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMCommunityCommentCell", for: indexPath) as! EMCommunityCommentCell
        cell.model = self.commentArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 40.w
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: section == 0 ? 0 : 40.w))
        view.themeBackgroundColor = .conversationButton_background
        let lab = UILabel(font: UIFont.Bold(size: 15),textColor: .textPrimary,text: "\(LocalComment.localized())(\(self.model.CommentCount))")
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(12.w)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendView.textView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoadMore || self.commentArr.count < 10{
            return
        }
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRow {
            isLoadMore = true
            getComment()
        }
    }
}
