// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMBannerView: UIView {
    
    public var defineQr: UIImage = UIImage()
    public var defineInviteCode: String = "" //邀请码
    public var defineName: String = "" //姓名
    public var titles: [String] = [] //姓名
    public var title2s: [String] = [] //姓名
    public var bgImages: [UIImage] = []
    /// isAutomatic
    public var isAutomatic: Bool = true
    /// isInfinite
    public var isInfinite: Bool = true {
        didSet {
            if isInfinite == false {
                itemsCount = realDataCount <= 1 || !isInfinite ? realDataCount : realDataCount*200
                collectionView.reloadData()
                collectionView.setContentOffset(.zero, animated: false)
                dealFirstPage()
            }
        }
    }
    
    /// scroll timeInterval
    public var timeInterval: Int = 2
    /// scrollDirection
    public var scrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet { flowLayout.scrollDirection = scrollDirection }
    }
    /// placeholderImage
    public var placeholderImage: UIImage? = nil {
        didSet { placeholderImgView.image = placeholderImage }
    }
    
    // MARK: - set image or image url or text
    // you can also set the desc `titlesGroup` or `attributedTitlesGroup`, pick one of two, `attributedTitlesGroup` first
    
    /// set local image
    public func setImagesGroup(_ imagesGroup: Array<UIImage?>, titlesGroup: [String?]? = nil, attributedTitlesGroup: [NSAttributedString?]? = nil) {
        if imagesGroup.count == 0 { return }
        resourceType = .image
        realDataCount = imagesGroup.count
        self.imagesGroup = imagesGroup
        setResource(titlesGroup, attributedTitlesGroup: attributedTitlesGroup)
    }
    /// set image url
    public func setUrlsGroup(_ urlsGroup: Array<String>, titlesGroup: [String?]? = nil, attributedTitlesGroup: [NSAttributedString?]? = nil) {
        if urlsGroup.count == 0 { return }
        resourceType = .imageURL
        realDataCount = urlsGroup.count
        self.imageUrlsGroup = urlsGroup
        setResource(titlesGroup, attributedTitlesGroup: attributedTitlesGroup)
        //         pageShowLabel.text = "1/\(realDataCount)"
    }
    /// set text
    public func setTitlesGroup(_ titlesGroup: Array<String?>?, attributedTitlesGroup: [NSAttributedString?]? = nil) {
        if attributedTitlesGroup == nil && titlesGroup == nil { return }
        resourceType = .text
        if attributedTitlesGroup != nil {
            if attributedTitlesGroup!.count == 0 { return }
            realDataCount = attributedTitlesGroup!.count
        } else {
            if titlesGroup!.count == 0 { return }
            realDataCount = titlesGroup!.count
        }
        setResource(titlesGroup, attributedTitlesGroup: attributedTitlesGroup)
    }
    
    // MARK: - If you want the effect in the picture below, use the following method
    // Special reminder, be sure to set the size, otherwise the picture does not display
    
    /// set image on title's left
    public func setTitleImagesGroup(_ titleImagesGroup: [UIImage?], sizeGroup:[CGSize?]) {
        self.titleImagesGroup = titleImagesGroup
        self.titleImageSizeGroup = sizeGroup
        collectionView.reloadData()
    }
    /// set image url on title's left
    public func setTitleImageUrlsGroup(_ titleImageUrlsGroup: [String?], sizeGroup:[CGSize?]) {
        self.titleImageUrlsGroup = titleImageUrlsGroup
        self.titleImageSizeGroup = sizeGroup
        collectionView.reloadData()
    }
    // MARK: - item setting
    /// The size of the item, the default cycleView size
    public var itemSize: CGSize? {
        didSet {
            if resourceType == .text { return }
            if let itemSize = itemSize {
                let width = min(bounds.size.width, itemSize.width)
                let height = min(bounds.size.height, itemSize.height)
                flowLayout.itemSize = CGSize(width: width, height: height)
            }
        }
    }
    /// The scale of the center item 中间item的放大比例
    public var itemZoomScale: CGFloat = 1 {
        didSet {
            if resourceType == .text { return }
            flowLayout.scale = itemZoomScale
        }
    }
    /// The space of items -- item 间距
    public var itemSpacing: CGFloat = 0 {
        didSet {
            if resourceType == .text { itemSpacing = 0; return }
            flowLayout.minimumLineSpacing = itemSpacing
        }
    }
    /// item CornerRadius
    public var itemCornerRadius: CGFloat = 0
    /// item BorderColor
    public var itemBorderColor: UIColor = UIColor.clear
    /// item BorderWidth
    public var itemBorderWidth: CGFloat = 0
    
    // MARK: - imageView Setting
    /// content Mode of item's image
    public var imageContentMode: UIView.ContentMode = .scaleToFill
    
    // MARK: - titleLabel setting
    /// The height of the desc containerView, if you set the left image, is also included
    public var titleViewHeight: CGFloat = 25
    /// titleAlignment
    public var titleAlignment: NSTextAlignment = .left
    /// desc font
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 13)
    /// The backgroundColor of the desc containerView
    public var titleBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    /// titleColor
    public var titleColor: UIColor = UIColor.white
    /// The number of lines of text displayed
    public var titleNumberOfLines = 1
    /// The breakMode of lines of text displayed
    public var titleLineBreakMode: NSLineBreakMode = .byWordWrapping
    
    // MARK: - PageControl setting
    
    /// Whether to hide pageControl, the default `false`
    public var pageControlIsHidden = false {
        didSet { pageControl.isHidden = pageControlIsHidden }
    }
    /// Dot color, the default `gray`
    public var pageControlIndictirColor = UIColor.gray {
        didSet { pageControl.pageIndicatorTintColor = pageControlIndictirColor }
    }
    /// Current dot color, the default `white`
    public var pageControlCurrentIndictirColor = UIColor.white {
        didSet { pageControl.currentPageIndicatorTintColor = pageControlCurrentIndictirColor }
    }
    /// The current dot image
    public var pageControlCurrentIndictorImage: UIImage? {
        didSet { pageControl.currentItemImage = pageControlCurrentIndictorImage }
    }
    /// The dot image
    public var pageControlIndictorImage: UIImage? {
        didSet { pageControl.itemImage = pageControlIndictorImage }
    }
    /// The height of pageControl, default `25`
    public var pageControlHeight: CGFloat = 25 {
        didSet {
            pageControl.frame = CGRect(x: 0, y: frame.size.height-pageControlHeight, width: frame.size.width, height: pageControlHeight)
            pageControl.updateFrame()
        }
    }
    
    public var pageControlFrame: CGRect = CGRect.zero {
        didSet {
            pageControl.frame = pageControlFrame
            pageControl.updateFrame()
        }
    }
    
    /// PageControl's backgroundColor
    public var pageControlBackgroundColor = UIColor.clear {
        didSet { pageControl.backgroundColor = pageControlBackgroundColor }
    }
    /// The size of all dots
    public var pageControlItemSize = CGSize(width: 8, height: 8) {
        didSet { pageControl.controlSize = pageControlItemSize }
    }
    /// The size of current dot
    public var pageControlCurrentItemSize: CGSize? {
        didSet { pageControl.currentControlSize = pageControlCurrentItemSize }
    }
    /// The space of dot
    public var pageControlSpacing: CGFloat = 8 {
        didSet { pageControl.controlSpacing = pageControlSpacing }
    }
    /// pageControl Alignment, left/right/center , default `center`
    public var pageControlAlignment: EMBannerControlAlignment = .center {
        didSet { pageControl.alignment = pageControlAlignment }
    }
    /// the radius of dot
    public var pageControlItemRadius: CGFloat? {
        didSet { pageControl.itemCornerRadius = pageControlItemRadius }
    }
    /// the radius of current dot
    public var pageControlCurrentItemRadius: CGFloat? {
        didSet { pageControl.currentItemCornerRadius = pageControlCurrentItemRadius }
    }
    
    // MARK: - closure
    // Click and scroll events are in the form of closures
    /// 点击了item
    public var didSelectedItem: ((Int)->())?
    /// 滚动到某一位置
    public var didScrollToIndex: ((Int)->())?
    // --- end ---------
    
    
    //=============================================
    fileprivate var pageShowLabel: UILabel!
    fileprivate var flowLayout: EMBannerLayout!
    var collectionView: UICollectionView!
    fileprivate var placeholderImgView: UIImageView!
    fileprivate var pageControl: EMBannerControl!
    fileprivate var imagesGroup: Array<UIImage?> = []
    fileprivate var imageUrlsGroup: Array<String> = []
    fileprivate var titlesGroup: [NSAttributedString?] = []
    fileprivate var titleImagesGroup: Array<UIImage?> = []
    fileprivate var titleImageUrlsGroup: Array<String?> = []
    fileprivate var titleImageSizeGroup: Array<CGSize?> = []
    fileprivate var timer: Timer?
    fileprivate var itemsCount: Int = 0
    fileprivate var realDataCount: Int = 0
    fileprivate var resourceType: ResourceType = .image
    override init(frame: CGRect) {
        super.init(frame: frame)
        addPlaceholderImgView()
        addCollectionView()
        addPageControl()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addPlaceholderImgView()
        addCollectionView()
        addPageControl()
        //        addDownShowPage()
    }
    private func addPlaceholderImgView() {
        placeholderImgView = UIImageView(frame: bounds)
        placeholderImgView.image = placeholderImage
        placeholderImgView.contentMode = .scaleToFill
        addSubview(placeholderImgView)
    }
    private func addCollectionView() {
        flowLayout = EMBannerLayout()
        flowLayout.itemSize = itemSize != nil ? itemSize! : bounds.size
        flowLayout.minimumInteritemSpacing = 10000
        flowLayout.minimumLineSpacing = itemSpacing
        flowLayout.scrollDirection = scrollDirection
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.register(EMBannerCell.self, forCellWithReuseIdentifier: "EMBannerCell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.0)
        addSubview(collectionView)
        
    }
    private func addPageControl() {
        pageControl = EMBannerControl(frame: CGRect(x: 0, y: bounds.size.height - pageControlHeight, width: bounds.size.width, height: pageControlHeight))
        
        addSubview(pageControl)
    }
    
    private func addDownShowPage(){
        let  showLabelW :CGFloat = 40
        let  showLabelH :CGFloat = 20
        
        pageShowLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width - showLabelW - 20 , y: 200 - showLabelH - 10, width: showLabelW, height: showLabelH))
        pageShowLabel.font = UIFont.systemFont(ofSize: 12)
        pageShowLabel.textColor = UIColor.black
        pageShowLabel.backgroundColor = UIColor.white
        pageShowLabel.textAlignment = NSTextAlignment.center
        pageShowLabel.layer.cornerRadius = 5
        pageShowLabel.layer.masksToBounds = true
        pageShowLabel.alpha = 0.5
        addSubview(pageShowLabel)
    }
    
    override public func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            self.startTimer()
        } else {
            self.cancelTimer()
        }
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.itemSize = itemSize != nil ? itemSize! : bounds.size
        collectionView.frame = bounds
        pageControl.frame = CGRect(x: 0, y: frame.size.height-pageControlHeight, width: frame.size.width, height: pageControlHeight)
        pageControl.updateFrame()
        
        collectionView.setContentOffset(.zero, animated: false)
        dealFirstPage()
    }
    
    private func setResource(_ titlesGroup: Array<String?>?, attributedTitlesGroup: [NSAttributedString?]?) {
        placeholderImgView.isHidden = true
        itemsCount = realDataCount <= 1 || !isInfinite ? realDataCount : realDataCount*200
        if attributedTitlesGroup != nil {
            self.titlesGroup = attributedTitlesGroup ?? []
        } else {
            let titles = titlesGroup?.map { return NSAttributedString(string: $0 ?? "") }
            self.titlesGroup = titles ?? []
        }
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
        dealFirstPage()
        pageControl.numberOfPages = realDataCount
        pageControl.currentPage = currentIndex() % realDataCount
        if resourceType == .text  {pageControl.isHidden = true}
        if isAutomatic { startTimer() }
    }
}

// MARK: - UICollectionViewDataSource/UICollectionViewDelegate
extension EMBannerView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsCount
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item % realDataCount
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EMBannerCell", for: indexPath) as! EMBannerCell
        switch resourceType {
        case .image:
            cell.imageView.image = imagesGroup[index]
        case .imageURL:
            cell.imageUrl(imageUrlsGroup[index], placeholder: placeholderImage)
        case .text:
            break
        }
        if resourceType != .text {
            cell.layer.borderWidth = itemBorderWidth
            cell.layer.borderColor = itemBorderColor.cgColor
            cell.layer.cornerRadius = itemCornerRadius
            cell.layer.masksToBounds = true
        }
        /// --------------------title setting-----------------------  ///
        cell.titleContainerViewH = resourceType == .text ? collectionView.bounds.size.height : titleViewHeight
        cell.titleLabel.textAlignment = titleAlignment
        cell.titleContainerView.backgroundColor = titleBackgroundColor
        cell.titleLabel.font = titleFont
        cell.titleLabel.numberOfLines = titleNumberOfLines
        cell.titleLabel.textColor = titleColor
        let title = index < titlesGroup.count ? titlesGroup[index] : nil
        let titleImage = index < titleImagesGroup.count ? titleImagesGroup[index] : nil
        let titleImageUrl = index < titleImageUrlsGroup.count ? titleImageUrlsGroup[index] : nil
        let titleImageSize = index < titleImageSizeGroup.count ? titleImageSizeGroup[index] : nil
        cell.attributeString(title, titleImgURL: titleImageUrl, titleImage: titleImage, titleImageSize: titleImageSize)
        /// --------------imgView setting----------------------------  ///
        cell.imageView.contentMode = imageContentMode
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let centerViewPoint = convert(collectionView.center, to: collectionView)
        if let centerIndex = collectionView.indexPathForItem(at: centerViewPoint) {
            if indexPath.item == centerIndex.item {
                let index = indexPath.item % realDataCount
                if didSelectedItem != nil {
                    didSelectedItem!(index)
                }
            } else {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension EMBannerView {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutomatic { cancelTimer() }
        dealLastPage()
        dealFirstPage()
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutomatic { startTimer() }
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = currentIndex() % realDataCount
        pageControl?.currentPage = index
        //        pageShowLabel.text = "\(index + 1)/\(realDataCount)"
        if didScrollToIndex != nil {
            didScrollToIndex!(index)
            
        }
        
    }
}

// MARK: - deal the first page and last page
extension EMBannerView {
    fileprivate func dealFirstPage() {
        if currentIndex() == 0 && itemsCount > 1 && isInfinite {
            let targetIndex = itemsCount / 2
            let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
            collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: false)
            if didScrollToIndex != nil {
                didScrollToIndex!(0)
            }
        }
    }
    fileprivate func dealLastPage() {
        if currentIndex() == itemsCount-1 && itemsCount > 1 && isInfinite {
            let targetIndex = itemsCount / 2 - 1
            let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
            collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: false)
        }
    }
}


// MARK: - timer
extension EMBannerView {
    fileprivate func startTimer() {
        if !isAutomatic { return }
        if itemsCount <= 1 { return }
        cancelTimer()
        timer = Timer.init(timeInterval: Double(timeInterval), target: self, selector: #selector(timeRepeat), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    fileprivate func cancelTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func timeRepeat() {
        let current = currentIndex()
        var targetIndex = current + 1
        if (current == itemsCount - 1) {
            if isInfinite == false {return}
            dealLastPage()
            targetIndex = itemsCount / 2
        }
        let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: true)
    }
    
    fileprivate func currentIndex() -> Int {
        let itemWH = scrollDirection == .horizontal ? flowLayout.itemSize.width+itemSpacing : flowLayout.itemSize.height+itemSpacing
        let offsetXY = scrollDirection == .horizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
        if itemWH == 0 { return 0 }
        let index = round(offsetXY / itemWH)
        return Int(index)
    }
}

