// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import AVKit
import GRDB
import DifferenceKit
import SessionUIKit
import SessionMessagingKit
import SessionUtilitiesKit
import SignalUtilitiesKit

class ConversationSearchVC: BaseVC, ConversationSearchControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    internal let viewModel: ConversationViewModel
    private var dataChangeObservable: DatabaseCancellable?
    private var hasLoadedInitialThreadData: Bool = false
    private var hasLoadedInitialInteractionData: Bool = false
    private var currentTargetOffset: CGPoint?
    private var isAutoLoadingNextPage: Bool = false
    private var isLoadingMore: Bool = false
    var isReplacingThread: Bool = false
    
    /// This flag indicates whether the thread data has been reloaded after a disappearance (it defaults to true as it will
    /// never have disappeared before - this is only needed for value observers since they run asynchronously)
    private var hasReloadedThreadDataAfterDisappearance: Bool = true
    
    var focusedInteractionId: Int64?
    var shouldHighlightNextScrollToInteraction: Bool = false
    var scrollButtonBottomConstraint: NSLayoutConstraint?
    var scrollButtonMessageRequestsBottomConstraint: NSLayoutConstraint?
    var scrollButtonPendingMessageRequestInfoBottomConstraint: NSLayoutConstraint?
    var messageRequestsViewBotomConstraint: NSLayoutConstraint?
    
    // Audio playback & recording
    var audioPlayer: OWSAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var audioTimer: Timer?
    
    private var searchBarWidth: NSLayoutConstraint?
    
    // Context menu
    var contextMenuWindow: ContextMenuWindow?
    var contextMenuVC: ContextMenuVC?
    
    // Mentions
    var currentMentionStartIndex: String.Index?
    var mentions: [MentionInfo] = []
    
    // Scrolling & paging
    var isUserScrolling = false
    var hasPerformedInitialScroll = false
    var didFinishInitialLayout = false
    var scrollDistanceToBottomBeforeUpdate: CGFloat?
    var baselineKeyboardHeight: CGFloat = 0
    
    /// These flags are true between `viewDid/Will Appear/Disappear` and is used to prevent keyboard changes
    /// from trying to animate (as the animations can cause buggy transitions)
    var viewIsDisappearing = false
    var viewIsAppearing = false
    
    // Reaction
    var currentReactionListSheet: ReactionListSheet?
    var reactionExpandedMessageIds: Set<String> = []

    /// This flag is used to temporarily prevent the ConversationVC from becoming the first responder (primarily used with
    /// custom transitions from preventing them from being buggy
    var delayFirstResponder: Bool = false
    override var canBecomeFirstResponder: Bool {
        !delayFirstResponder &&
        
        // Need to return false during the swap between threads to prevent keyboard dismissal
        !isReplacingThread
    }
    
    override var inputAccessoryView: UIView? {
        guard viewModel.threadData.canWrite else { return nil }
        
        return searchController.resultsBar
    }

    /// The height of the visible part of the table view, i.e. the distance from the navigation bar (where the table view's origin is)
    /// to the top of the input view (`tableView.adjustedContentInset.bottom`).
    var tableViewUnobscuredHeight: CGFloat {
        let bottomInset = tableView.adjustedContentInset.bottom
        return tableView.bounds.height - bottomInset
    }

    /// The offset at which the table view is exactly scrolled to the bottom.
    var lastPageTop: CGFloat {
        return tableView.contentSize.height - tableViewUnobscuredHeight
    }

    var isCloseToBottom: Bool {
        let margin = (self.lastPageTop - self.tableView.contentOffset.y)
        return margin <= ConversationVC.scrollToBottomMargin
    }

    lazy var mnemonic: String = {
        if let seed: Data = Identity.fetchHexEncodedSeed() {
            return Mnemonic.encode(entropy: seed)
        }

        // Legacy account
        return Mnemonic.encode(entropy: Identity.fetchUserPrivateKey()!)
    }()

    // FIXME: Would be good to create a Swift-based cache and replace this
    lazy var mediaCache: NSCache<NSString, AnyObject> = {
        let result = NSCache<NSString, AnyObject>()
        result.countLimit = 40
        return result
    }()

    lazy var recordVoiceMessageActivity = AudioActivity(audioDescription: "Voice message", behavior: .playAndRecord)

    lazy var searchController: ConversationSearchController = {
        let result: ConversationSearchController = ConversationSearchController(
            threadId: self.viewModel.threadData.threadId
        )
        result.uiSearchController.obscuresBackgroundDuringPresentation = false
        result.delegate = self
        
        return result
    }()

    lazy var tableView: InsetLockableTableView = {
        let result: InsetLockableTableView = InsetLockableTableView()
        result.separatorStyle = .none
        result.themeBackgroundColor = .clear
        result.showsVerticalScrollIndicator = false
        result.contentInsetAdjustmentBehavior = .never
        result.keyboardDismissMode = .interactive
        result.contentInset = UIEdgeInsets(
            top: 0,
            leading: 0,
            bottom: (viewModel.threadData.canWrite ?
                Values.mediumSpacing :
                (Values.mediumSpacing + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0))
            ),
            trailing: 0
        )
        result.registerHeaderFooterView(view: UITableViewHeaderFooterView.self)
        result.register(view: DateHeaderCell.self)
        result.register(view: VisibleMessageCell.self)
        result.register(view: InfoMessageCell.self)
        result.register(view: TypingIndicatorCell.self)
        result.register(view: CallMessageCell.self)
        result.dataSource = self
        result.delegate = self

        return result
    }()


    lazy var footerControlsStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .trailing
        result.distribution = .equalSpacing
        result.spacing = 10
        result.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        result.isLayoutMarginsRelativeArrangement = true

        return result
    }()

    
    // MARK: - Settings
    
    static let unreadCountViewSize: CGFloat = 20
    /// The table view's bottom inset (content will have this distance to the bottom if the table view is fully scrolled down).
    static let bottomInset = Values.mediumSpacing
    /// The table view will start loading more content when the content offset becomes less than this.
    static let loadMoreThreshold: CGFloat = 120
    /// The button will be fully visible once the user has scrolled this amount from the bottom of the table view.
    static let scrollButtonFullVisibilityThreshold: CGFloat = 80
    /// The button will be invisible until the user has scrolled at least this amount from the bottom of the table view.
    static let scrollButtonNoVisibilityThreshold: CGFloat = 20
    /// Automatically scroll to the bottom of the conversation when sending a message if the scroll distance from the bottom is less than this number.
    static let scrollToBottomMargin: CGFloat = 60

    // MARK: - Initialization
    
    init(threadId: String, threadVariant: SessionThread.Variant, focusedInteractionId: Int64? = nil) {
        self.viewModel = ConversationViewModel(threadId: threadId, threadVariant: threadVariant, focusedInteractionId: focusedInteractionId)
        
        Storage.shared.addObserver(viewModel.pagedDataObserver)
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Use init(thread:) instead.")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateNavBarButtons(threadData: nil, initialVariant: self.viewModel.initialThreadVariant)
        
        // Constraints
        view.addSubview(tableView)
        tableView.pin(to: view)
        // Notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidResignActive(_:)),
            name: UIApplication.didEnterBackgroundNotification, object: nil
        )
        showSearchUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startObservingChanges()
        
        viewIsAppearing = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { [weak self] in
            self?.searchController.uiSearchController.searchBar.becomeFirstResponder()
        }
        self.didFinishInitialLayout = true
        self.viewIsAppearing = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewIsDisappearing = true
        guard !isReplacingThread else { return }
        stopObservingChanges()
        inputAccessoryView?.resignFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mediaCache.removeAllObjects()
        hasReloadedThreadDataAfterDisappearance = false
        viewIsDisappearing = false
    }
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        /// Need to dispatch to the next run loop to prevent a possible crash caused by the database resuming mid-query
        DispatchQueue.main.async { [weak self] in
            self?.startObservingChanges(didReturnFromBackground: true)
        }
    }
    
    @objc func applicationDidResignActive(_ notification: Notification) {
        stopObservingChanges()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        searchBarWidth?.constant = size.width - 32
        tableView.reloadData()
    }
    
    // MARK: - Updating
    
    private func startObservingChanges(didReturnFromBackground: Bool = false) {
        // Start observing for data changes
        dataChangeObservable = Storage.shared.start(
            viewModel.observableThreadData,
            onError:  { _ in },
            onChange: { [weak self] maybeThreadData in
                guard let threadData: SessionThreadViewModel = maybeThreadData else {
                    // If the thread data is null and the id was blinded then we just unblinded the thread
                    // and need to swap over to the new one
                    guard
                        let sessionId: String = self?.viewModel.threadData.threadId,
                        SessionId.Prefix(from: sessionId) == .blinded,
                        let blindedLookup: BlindedIdLookup = Storage.shared.read({ db in
                            try BlindedIdLookup
                                .filter(id: sessionId)
                                .fetchOne(db)
                        }),
                        let unblindedId: String = blindedLookup.sessionId
                    else {
                        // If we don't have an unblinded id then something has gone very wrong so pop to the HomeVC
                        self?.navigationController?.popToRootViewController(animated: true)
                        return
                    }
                    
                    // Stop observing changes
                    self?.stopObservingChanges()
                    Storage.shared.removeObserver(self?.viewModel.pagedDataObserver)
                    
                    // Swap the observing to the updated thread
                    self?.viewModel.swapToThread(updatedThreadId: unblindedId)
                    
                    // Start observing changes again
                    Storage.shared.addObserver(self?.viewModel.pagedDataObserver)
                    self?.startObservingChanges()
                    return
                }
                
                // The default scheduler emits changes on the main thread
                self?.handleThreadUpdates(threadData)
                
                // Note: We want to load the interaction data into the UI after the initial thread data
                // has loaded to prevent an issue where the conversation loads with the wrong offset
                if self?.viewModel.onInteractionChange == nil {
                    self?.viewModel.onInteractionChange = { [weak self] updatedInteractionData, changeset in
                        self?.handleInteractionUpdates(updatedInteractionData, changeset: changeset)
                    }
                    
                    // Note: When returning from the background we could have received notifications but the
                    // PagedDatabaseObserver won't have them so we need to force a re-fetch of the current
                    // data to ensure everything is up to date
                    if didReturnFromBackground {
                        self?.viewModel.pagedDataObserver?.reload()
                    }
                }
            }
        )
    }
    
    private func stopObservingChanges() {
        // Stop observing database changes
        dataChangeObservable?.cancel()
        self.viewModel.onInteractionChange = nil
    }
    
    private func handleThreadUpdates(_ updatedThreadData: SessionThreadViewModel, initialLoad: Bool = false) {
        // Ensure the first load or a load when returning from a child screen runs without animations (if
        // we don't do this the cells will animate in from a frame of CGRect.zero or have a buggy transition)
        guard hasLoadedInitialThreadData && hasReloadedThreadDataAfterDisappearance else {
            // Need to correctly determine if it's the initial load otherwise we would be needlesly updating
            // extra UI elements
            let isInitialLoad: Bool = (
                !hasLoadedInitialThreadData &&
                hasReloadedThreadDataAfterDisappearance
            )
            hasLoadedInitialThreadData = true
            hasReloadedThreadDataAfterDisappearance = true
            
            UIView.performWithoutAnimation {
                handleThreadUpdates(updatedThreadData, initialLoad: isInitialLoad)
            }
            return
        }
        
        
        
        if
            initialLoad ||
            viewModel.threadData.threadRequiresApproval != updatedThreadData.threadRequiresApproval ||
            viewModel.threadData.threadIsMessageRequest != updatedThreadData.threadIsMessageRequest ||
            viewModel.threadData.profile != updatedThreadData.profile
        {
            updateNavBarButtons(threadData: updatedThreadData, initialVariant: viewModel.initialThreadVariant)
            
        }
        
        // Now we have done all the needed diffs update the viewModel with the latest data
        self.viewModel.updateThreadData(updatedThreadData)
        
        /// **Note:** This needs to happen **after** we have update the viewModel's thread data
        if initialLoad || viewModel.threadData.currentUserIsClosedGroupMember != updatedThreadData.currentUserIsClosedGroupMember {
            if !self.isFirstResponder {
                self.becomeFirstResponder()
            }
            else {
                self.reloadInputViews()
            }
        }
    }
    
    private func handleInteractionUpdates(
        _ updatedData: [ConversationViewModel.SectionModel],
        changeset: StagedChangeset<[ConversationViewModel.SectionModel]>,
        initialLoad: Bool = false
    ) {
        // Ensure the first load or a load when returning from a child screen runs without
        // animations (if we don't do this the cells will animate in from a frame of
        // CGRect.zero or have a buggy transition)
        guard self.hasLoadedInitialInteractionData else {
            // Need to dispatch async to prevent this from causing glitches in the push animation
            DispatchQueue.main.async {
                self.hasLoadedInitialInteractionData = true
                self.viewModel.updateInteractionData(updatedData)
                
                UIView.performWithoutAnimation {
                    self.tableView.reloadData()
                    self.performInitialScrollIfNeeded()
                }
            }
            return
        }
        
        // Update the ReactionListSheet (if one exists)
        if let messageUpdates: [MessageViewModel] = updatedData.first(where: { $0.model == .messages })?.elements {
            self.currentReactionListSheet?.handleInteractionUpdates(messageUpdates)
        }
        
        // Store the 'sentMessageBeforeUpdate' state locally
        let didSendMessageBeforeUpdate: Bool = self.viewModel.sentMessageBeforeUpdate
        let wasOnlyUpdates: Bool = (
            changeset.count == 1 &&
            changeset[0].elementUpdated.count == changeset[0].changeCount
        )
        self.viewModel.sentMessageBeforeUpdate = false
        
        // When sending a message, or if there were only cell updates (ie. read status changes) we want to
        // reload the UI instantly (with any form of animation the message sending feels somewhat unresponsive
        // but an instant update feels snappy and without the instant update there is some overlap of the read
        // status text change even though there shouldn't be any animations)
        guard !didSendMessageBeforeUpdate && !wasOnlyUpdates else {
            self.viewModel.updateInteractionData(updatedData)
            self.tableView.reloadData()
            
            // Note: The scroll button alpha won't get set correctly in this case so we forcibly set it to
            // have an alpha of 0 to stop it appearing buggy
            self.scrollToBottom(isAnimated: false)
            return
        }
        
        // Reload the table content animating changes if they'll look good
        struct ItemChangeInfo {
            let isInsertAtTop: Bool
            let firstIndexIsVisible: Bool
            let visibleIndexPath: IndexPath
            let oldVisibleIndexPath: IndexPath
            
            init(
                isInsertAtTop: Bool = false,
                firstIndexIsVisible: Bool = false,
                visibleIndexPath: IndexPath = IndexPath(row: 0, section: 0),
                oldVisibleIndexPath: IndexPath = IndexPath(row: 0, section: 0)
            ) {
                self.isInsertAtTop = isInsertAtTop
                self.firstIndexIsVisible = firstIndexIsVisible
                self.visibleIndexPath = visibleIndexPath
                self.oldVisibleIndexPath = oldVisibleIndexPath
            }
        }
        
        let numItemsInserted: Int = changeset.map { $0.elementInserted.count }.reduce(0, +)
        let isInsert: Bool = (numItemsInserted > 0)
        let wasLoadingMore: Bool = self.isLoadingMore
        let wasOffsetCloseToBottom: Bool = self.isCloseToBottom
        let numItemsInUpdatedData: [Int] = updatedData.map { $0.elements.count }
        let didSwapAllContent: Bool = (updatedData
            .first(where: { $0.model == .messages })?
            .elements
            .contains(where: {
                $0.id == self.viewModel.interactionData
                .first(where: { $0.model == .messages })?
                .elements
                .first?
                .id
            }))
            .defaulting(to: false)
        let itemChangeInfo: ItemChangeInfo? = {
            guard
                isInsert,
                let oldSectionIndex: Int = self.viewModel.interactionData.firstIndex(where: { $0.model == .messages }),
                let newSectionIndex: Int = updatedData.firstIndex(where: { $0.model == .messages }),
                let newFirstItemIndex: Int = updatedData[newSectionIndex].elements
                    .firstIndex(where: { item -> Bool in
                        // Since the first item is probably a `DateHeaderCell` (which would likely
                        // be removed when inserting items above it) we check if the id matches
                        // either the first or second item
                        let messages: [MessageViewModel] = self.viewModel
                            .interactionData[oldSectionIndex]
                            .elements
                        
                        return (
                            item.id == messages[safe: 0]?.id ||
                            item.id == messages[safe: 1]?.id
                        )
                    }),
                let firstVisibleIndexPath: IndexPath = self.tableView.indexPathsForVisibleRows?
                    .filter({
                        $0.section == oldSectionIndex &&
                        self.viewModel.interactionData[$0.section].elements[$0.row].cellType != .dateHeader
                    })
                    .sorted()
                    .first,
                let newVisibleIndex: Int = updatedData[newSectionIndex].elements
                    .firstIndex(where: { item in
                        item.id == self.viewModel.interactionData[oldSectionIndex]
                            .elements[firstVisibleIndexPath.row]
                            .id
                    })
            else { return nil }
            
            return ItemChangeInfo(
                isInsertAtTop: (
                    newSectionIndex > oldSectionIndex ||
                    // Note: Using `1` here instead of `0` as the first item will generally
                    // be a `DateHeaderCell` instead of a message
                    newFirstItemIndex > 1
                ),
                firstIndexIsVisible: (firstVisibleIndexPath.row == 0),
                visibleIndexPath: IndexPath(row: newVisibleIndex, section: newSectionIndex),
                oldVisibleIndexPath: firstVisibleIndexPath
            )
        }()
        
        guard !isInsert || itemChangeInfo?.isInsertAtTop == true else {
            self.viewModel.updateInteractionData(updatedData)
            self.tableView.reloadData()
            
            // Animate to the target interaction (or the bottom) after a slightly delay to prevent buggy
            // animation conflicts
            if let focusedInteractionId: Int64 = self.focusedInteractionId {
                // If we had a focusedInteractionId then scroll to it (and hide the search
                // result bar loading indicator)
                let delay: DispatchTime = (didSwapAllContent ?
                    .now() :
                    (.now() + .milliseconds(100))
                )
                
                DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
                    self?.searchController.resultsBar.stopLoading()
                    self?.scrollToInteractionIfNeeded(
                        with: focusedInteractionId,
                        isAnimated: true,
                        highlight: (self?.shouldHighlightNextScrollToInteraction == true)
                    )
                    
                    if wasLoadingMore {
                        // Complete page loading
                        self?.isLoadingMore = false
                        self?.autoLoadNextPageIfNeeded()
                    }
                }
            }
            else if wasOffsetCloseToBottom && !wasLoadingMore && numItemsInserted < 5 {
                /// Scroll to the bottom if an interaction was just inserted and we either just sent a message or are close enough to the
                /// bottom (wait a tiny fraction to avoid buggy animation behaviour)
                ///
                /// **Note:** We won't automatically scroll to the bottom if 5 or more messages were inserted (to avoid endlessly
                /// auto-scrolling to the bottom when fetching new pages of data within open groups
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
                    self?.scrollToBottom(isAnimated: true)
                }
            }
            else if wasLoadingMore {
                // Complete page loading
                self.isLoadingMore = false
                self.autoLoadNextPageIfNeeded()
            }
            else {
            }
            return
        }
        
        /// UITableView doesn't really support bottom-aligned content very well and as such jumps around a lot when inserting content but
        /// we want to maintain the current offset from before the data was inserted (except when adding at the bottom while the user is at
        /// the bottom, in which case we want to scroll down)
        ///
        /// Unfortunately the UITableView also does some weird things when updating (where it won't have updated it's internal data until
        /// after it performs the next layout); the below code checks a condition on layout and if it passes it calls a closure
        if let itemChangeInfo: ItemChangeInfo = itemChangeInfo, itemChangeInfo.isInsertAtTop {
            let oldCellRect: CGRect = self.tableView.rectForRow(at: itemChangeInfo.oldVisibleIndexPath)
            let oldCellTopOffset: CGFloat = (self.tableView.frame.minY - self.tableView.convert(oldCellRect, to: self.tableView.superview).minY)
            
            // The the user triggered the 'scrollToTop' animation (by tapping in the nav bar) then we
            // need to stop the animation before attempting to lock the offset (otherwise things break)
            if itemChangeInfo.firstIndexIsVisible {
                self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
            }
            
            // Wait until the tableView has completed a layout and reported the correct number of
            // sections/rows and then update the contentOffset
            self.tableView.afterNextLayoutSubviews(
                when: { numSections, numRowsInSections, _ -> Bool in
                    numSections == updatedData.count &&
                    numRowsInSections == numItemsInUpdatedData
                },
                then: { [weak self] in
                    // Only recalculate the contentOffset when loading new data if the amount of data
                    // loaded was smaller than 2 pages (this will prevent calculating the frames of
                    // a large number of cells when getting search results which are very far away
                    // only to instantly start scrolling making the calculation redundant)
                    UIView.performWithoutAnimation {
                        self?.tableView.scrollToRow(
                            at: itemChangeInfo.visibleIndexPath,
                            at: .top,
                            animated: false
                        )
                        self?.tableView.contentOffset.y += oldCellTopOffset
                    }
                    
                    if let focusedInteractionId: Int64 = self?.focusedInteractionId {
                        DispatchQueue.main.async { [weak self] in
                            // If we had a focusedInteractionId then scroll to it (and hide the search
                            // result bar loading indicator)
                            self?.searchController.resultsBar.stopLoading()
                            self?.scrollToInteractionIfNeeded(
                                with: focusedInteractionId,
                                isAnimated: true,
                                highlight: (self?.shouldHighlightNextScrollToInteraction == true)
                            )
                        }
                    }
                    
                    // Complete page loading
                    self?.isLoadingMore = false
                    self?.autoLoadNextPageIfNeeded()
                }
            )
        }
        else if wasLoadingMore {
            if let focusedInteractionId: Int64 = self.focusedInteractionId {
                DispatchQueue.main.async { [weak self] in
                    // If we had a focusedInteractionId then scroll to it (and hide the search
                    // result bar loading indicator)
                    self?.searchController.resultsBar.stopLoading()
                    self?.scrollToInteractionIfNeeded(
                        with: focusedInteractionId,
                        isAnimated: true,
                        highlight: (self?.shouldHighlightNextScrollToInteraction == true)
                    )
                    
                    // Complete page loading
                    self?.isLoadingMore = false
                    self?.autoLoadNextPageIfNeeded()
                }
            }
            else {
                // Complete page loading
                self.isLoadingMore = false
                self.autoLoadNextPageIfNeeded()
            }
        }
        
        // Update the messages
        self.tableView.reload(
            using: changeset,
            deleteSectionsAnimation: .none,
            insertSectionsAnimation: .none,
            reloadSectionsAnimation: .none,
            deleteRowsAnimation: .fade,
            insertRowsAnimation: .none,
            reloadRowsAnimation: .none,
            interrupt: { itemChangeInfo?.isInsertAtTop == true || $0.changeCount > ConversationViewModel.pageSize }
        ) { [weak self] updatedData in
            self?.viewModel.updateInteractionData(updatedData)
        }
    }
    
    // MARK: Updating
    
    private func performInitialScrollIfNeeded() {
        guard !hasPerformedInitialScroll && hasLoadedInitialThreadData && hasLoadedInitialInteractionData else {
            return
        }
        
        // Scroll to the last unread message if possible; otherwise scroll to the bottom.
        // When the unread message count is more than the number of view items of a page,
        // the screen will scroll to the bottom instead of the first unread message
        if let focusedInteractionId: Int64 = self.viewModel.focusedInteractionId {
            self.scrollToInteractionIfNeeded(with: focusedInteractionId, isAnimated: false, highlight: true)
        }
        else {
            self.scrollToBottom(isAnimated: false)
        }

        self.hasPerformedInitialScroll = true
        
        // Now that the data has loaded we need to check if either of the "load more" sections are
        // visible and trigger them if so
        //
        // Note: We do it this way as we want to trigger the load behaviour for the first section
        // if it has one before trying to trigger the load behaviour for the last section
        self.autoLoadNextPageIfNeeded()
    }
    
    private func autoLoadNextPageIfNeeded() {
        guard !self.isAutoLoadingNextPage && !self.isLoadingMore else { return }
        
        self.isAutoLoadingNextPage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + PagedData.autoLoadNextPageDelay) { [weak self] in
            self?.isAutoLoadingNextPage = false
            
            // Note: We sort the headers as we want to prioritise loading newer pages over older ones
            let sections: [(ConversationViewModel.Section, CGRect)] = (self?.viewModel.interactionData
                .enumerated()
                .map { index, section in (section.model, (self?.tableView.rectForHeader(inSection: index) ?? .zero)) })
                .defaulting(to: [])
            let shouldLoadOlder: Bool = sections
                .contains { section, headerRect in
                    section == .loadOlder &&
                    headerRect != .zero &&
                    (self?.tableView.bounds.contains(headerRect) == true)
                }
            let shouldLoadNewer: Bool = sections
                .contains { section, headerRect in
                    section == .loadNewer &&
                    headerRect != .zero &&
                    (self?.tableView.bounds.contains(headerRect) == true)
                }
            
            guard shouldLoadOlder || shouldLoadNewer else { return }
            
            self?.isLoadingMore = true
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                // Attachments are loaded in descending order so 'loadOlder' actually corresponds with
                // 'pageAfter' in this case
                self?.viewModel.pagedDataObserver?.load(shouldLoadOlder ?
                    .pageAfter :
                    .pageBefore
                )
            }
        }
    }
    
    func updateNavBarButtons(threadData: SessionThreadViewModel?, initialVariant: SessionThread.Variant) {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = []
    }


    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.interactionData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section: ConversationViewModel.SectionModel = viewModel.interactionData[section]
        
        return section.elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section: ConversationViewModel.SectionModel = viewModel.interactionData[indexPath.section]
        
        switch section.model {
            case .messages:
                let cellViewModel: MessageViewModel = section.elements[indexPath.row]
                let cell: MessageCell = tableView.dequeue(type: MessageCell.cellType(for: cellViewModel), for: indexPath)
                cell.update(
                    with: cellViewModel,
                    mediaCache: mediaCache,
                    playbackInfo: viewModel.playbackInfo(for: cellViewModel) { updatedInfo, error in
                        DispatchQueue.main.async { [weak self] in
                            guard error == nil else {
                                let modal: ConfirmationModal = ConfirmationModal(
                                    targetView: self?.view,
                                    info: ConfirmationModal.Info(
                                        title: CommonStrings.errorAlertTitle,
                                        body: .text("INVALID_AUDIO_FILE_ALERT_ERROR_MESSAGE".localized()),
                                        cancelTitle: "BUTTON_OK".localized(),
                                        cancelStyle: .alert_text
                                    )
                                )
                                self?.present(modal, animated: true)
                                return
                            }
                            
                            cell.dynamicUpdate(with: cellViewModel, playbackInfo: updatedInfo)
                        }
                    },
                    showExpandedReactions: viewModel.reactionExpandedInteractionIds
                        .contains(cellViewModel.id),
                    lastSearchText: viewModel.lastSearchedText
                )
                
                return cell
                
            default: preconditionFailure("Other sections should have no content")
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section: ConversationViewModel.SectionModel = viewModel.interactionData[section]
        
        switch section.model {
            case .loadOlder, .loadNewer:
                let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
                loadingIndicator.themeTintColor = .textPrimary
                loadingIndicator.alpha = 0.5
                loadingIndicator.startAnimating()
                
                let view: UIView = UIView()
                view.addSubview(loadingIndicator)
                loadingIndicator.center(in: view)
                
                return view
            
            case .messages: return nil
        }
    }
    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard self.hasPerformedInitialScroll && !self.isLoadingMore else { return }
        
        let section: ConversationViewModel.SectionModel = self.viewModel.interactionData[section]
        
        switch section.model {
            case .loadOlder, .loadNewer:
                self.isLoadingMore = true
                
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    // Messages are loaded in descending order so 'loadOlder' actually corresponds with
                    // 'pageAfter' in this case
                    self?.viewModel.pagedDataObserver?.load(section.model == .loadOlder ?
                        .pageAfter :
                        .pageBefore
                    )
                }
                
            case .messages: break
        }
    }

    func scrollToBottom(isAnimated: Bool) {
        guard
            !self.isUserScrolling,
            let messagesSectionIndex: Int = self.viewModel.interactionData
                .firstIndex(where: { $0.model == .messages }),
            !self.viewModel.interactionData[messagesSectionIndex]
                .elements
                .isEmpty
        else { return }
        
        // If the last interaction isn't loaded then scroll to the final interactionId on
        // the thread data
        let hasNewerItems: Bool = self.viewModel.interactionData.contains(where: { $0.model == .loadNewer })
        
        guard !self.didFinishInitialLayout || !hasNewerItems else {
            let messages: [MessageViewModel] = self.viewModel.interactionData[messagesSectionIndex].elements
            let lastInteractionId: Int64 = self.viewModel.threadData.interactionId
                .defaulting(to: messages[messages.count - 1].id)
            
            self.scrollToInteractionIfNeeded(
                with: lastInteractionId,
                position: .bottom,
                isJumpingToLastInteraction: true,
                isAnimated: true
            )
            return
        }
        
        // Note: In this case we need to force a tableView layout to ensure updating the
        // scroll position has the correct offset (otherwise there are some cases where
        // the screen will jump up - eg. when sending a reply while the soft keyboard
        // is visible)
        UIView.performWithoutAnimation {
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
        }
        
        let targetIndexPath: IndexPath = IndexPath(
            row: (self.viewModel.interactionData[messagesSectionIndex].elements.count - 1),
            section: messagesSectionIndex
        )
        self.tableView.scrollToRow(
            at: targetIndexPath,
            at: .bottom,
            animated: isAnimated
        )
        
        self.viewModel.markAsRead(beforeInclusive: nil)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserScrolling = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isUserScrolling = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We want to mark messages as read while we scroll, so grab the newest message and mark
        // everything older as read
        //
        // Note: For the 'tableVisualBottom' we remove the 'Values.mediumSpacing' as that is the distance
        // the table content appears above the input view
        let tableVisualBottom: CGFloat = (tableView.frame.maxY - (tableView.contentInset.bottom - Values.mediumSpacing))
        
        if
            let visibleIndexPaths: [IndexPath] = self.tableView.indexPathsForVisibleRows,
            let messagesSection: Int = visibleIndexPaths
                .first(where: { self.viewModel.interactionData[$0.section].model == .messages })?
                .section,
            let newestCellViewModel: MessageViewModel = visibleIndexPaths
                .sorted()
                .filter({ $0.section == messagesSection })
                .compactMap({ indexPath -> (frame: CGRect, cellViewModel: MessageViewModel)? in
                    guard let frame: CGRect = tableView.cellForRow(at: indexPath)?.frame else {
                        return nil
                    }
                    
                    return (
                        view.convert(frame, from: tableView),
                        self.viewModel.interactionData[indexPath.section].elements[indexPath.row]
                    )
                })
                // Exclude messages that are partially off the bottom of the screen
                .filter({ $0.frame.maxY <= tableVisualBottom })
                .last?
                .cellViewModel
        {
            self.viewModel.markAsRead(beforeInclusive: newestCellViewModel.id)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard
            let focusedInteractionId: Int64 = self.focusedInteractionId,
            self.shouldHighlightNextScrollToInteraction
        else {
            self.focusedInteractionId = nil
            self.shouldHighlightNextScrollToInteraction = false
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.highlightCellIfNeeded(interactionId: focusedInteractionId)
        }
    }


    func getScrollButtonOpacity() -> CGFloat {
        let contentOffsetY = tableView.contentOffset.y
        let x = (lastPageTop - ConversationVC.bottomInset - contentOffsetY).clamp(0, .greatestFiniteMagnitude)
        let a = 1 / (ConversationVC.scrollButtonFullVisibilityThreshold - ConversationVC.scrollButtonNoVisibilityThreshold)
        return max(0, min(1, a * x))
    }

    // MARK: - Search
    
    func popAllConversationSettingsViews(completion completionBlock: (() -> Void)? = nil) {
        if presentedViewController != nil {
            dismiss(animated: true) { [weak self] in
                guard let strongSelf: UIViewController = self else { return }
                
                self?.navigationController?.popToViewController(strongSelf, animated: true, completion: completionBlock)
            }
        }
        else {
            navigationController?.popToViewController(self, animated: true, completion: completionBlock)
        }
    }
    
    func showSearchUI() {
        
        // Search bar
        let searchBar = searchController.uiSearchController.searchBar
        searchBar.setUpSessionStyle()
        
        let searchBarContainer = UIView()
        searchBarContainer.layoutMargins = UIEdgeInsets.zero
        searchBar.sizeToFit()
        searchBar.layoutMargins = UIEdgeInsets.zero
        searchBarContainer.set(.height, to: 44)
        searchBarWidth = searchBarContainer.set(.width, to: UIScreen.main.bounds.width - 32)
        searchBarContainer.addSubview(searchBar)
        navigationItem.titleView = searchBarContainer
        
        // On iPad, the cancel button won't show
        // See more https://developer.apple.com/documentation/uikit/uisearchbar/1624283-showscancelbutton?language=objc
        if UIDevice.current.isIPad {
            let ipadCancelButton = UIButton()
            ipadCancelButton.setTitle(LocalCancel.localized(), for: .normal)
            ipadCancelButton.addTarget(self, action: #selector(back), for: .touchUpInside)
            ipadCancelButton.setThemeTitleColor(.textPrimary, for: .normal)
            searchBarContainer.addSubview(ipadCancelButton)
            ipadCancelButton.pin(.trailing, to: .trailing, of: searchBarContainer)
            ipadCancelButton.autoVCenterInSuperview()
            searchBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .trailing)
            searchBar.pin(.trailing, to: .leading, of: ipadCancelButton, withInset: -Values.smallSpacing)
        }
        else {
            searchBar.autoPinEdgesToSuperviewMargins()
        }
        
        // Nav bar buttons
        updateNavBarButtons(threadData: self.viewModel.threadData, initialVariant: viewModel.initialThreadVariant)
        
        // Hack so that the ResultsBar stays on the screen when dismissing the search field
        // keyboard.
        //
        // Details:
        //
        // When the search UI is activated, both the SearchField and the ConversationVC
        // have the resultsBar as their inputAccessoryView.
        //
        // So when the SearchField is first responder, the ResultsBar is shown on top of the keyboard.
        // When the ConversationVC is first responder, the ResultsBar is shown at the bottom of the
        // screen.
        //
        // When the user swipes to dismiss the keyboard, trying to see more of the content while
        // searching, we want the ResultsBar to stay at the bottom of the screen - that is, we
        // want the ConversationVC to becomeFirstResponder.
        //
        // If the SearchField were a subview of ConversationVC.view, this would all be automatic,
        // as first responder status is percolated up the responder chain via `nextResponder`, which
        // basically travereses each superView, until you're at a rootView, at which point the next
        // responder is the ViewController which controls that View.
        //
        // However, because SearchField lives in the Navbar, it's "controlled" by the
        // NavigationController, not the ConversationVC.
        //
        // So here we stub the next responder on the navBar so that when the searchBar resigns
        // first responder, the ConversationVC will be in it's responder chain - keeeping the
        // ResultsBar on the bottom of the screen after dismissing the keyboard.
        searchController.uiSearchController.stubbableSearchBar.stubbedNextResponder = self
    }

    @objc func back(){
        self.navigationController?.popViewController(animated: true)
    }
    

    func conversationSearchController(_ conversationSearchController: ConversationSearchController, didUpdateSearchResults results: [Int64]?, searchText: String?) {
        viewModel.lastSearchedText = searchText
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: UITableView.RowAnimation.none)
    }

    func conversationSearchController(_ conversationSearchController: ConversationSearchController, didSelectInteractionId interactionId: Int64) {
        scrollToInteractionIfNeeded(with: interactionId, highlight: true)
    }

    func scrollToInteractionIfNeeded(
        with interactionId: Int64,
        position: UITableView.ScrollPosition = .middle,
        isJumpingToLastInteraction: Bool = false,
        isAnimated: Bool = true,
        highlight: Bool = false
    ) {
        // Store the info incase we need to load more data (call will be re-triggered)
        self.focusedInteractionId = interactionId
        self.shouldHighlightNextScrollToInteraction = highlight
        self.viewModel.markAsRead(beforeInclusive: interactionId)
        
        // Ensure the target interaction has been loaded
        guard
            let messageSectionIndex: Int = self.viewModel.interactionData
                .firstIndex(where: { $0.model == .messages }),
            let targetMessageIndex = self.viewModel.interactionData[messageSectionIndex]
                .elements
                .firstIndex(where: { $0.id == interactionId })
        else {
            // If not the make sure we have finished the initial layout before trying to
            // load the up until the specified interaction
            guard self.didFinishInitialLayout else { return }
            
            self.isLoadingMore = true
            self.searchController.resultsBar.startLoading()
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if isJumpingToLastInteraction {
                    self?.viewModel.pagedDataObserver?.load(.jumpTo(
                        id: interactionId,
                        paddingForInclusive: 5
                    ))
                }
                else {
                    self?.viewModel.pagedDataObserver?.load(.untilInclusive(
                        id: interactionId,
                        padding: 5
                    ))
                }
            }
            return
        }
        
        // Note: If the tableView needs to layout then we should do it first without an animation
        // to prevent an annoying issue where the screen jumps slightly after the scroll completes
        UIView.performWithoutAnimation {
            self.tableView.layoutIfNeeded()
        }
        
        let targetIndexPath: IndexPath = IndexPath(
            row: targetMessageIndex,
            section: messageSectionIndex
        )
        
        // If we aren't animating or aren't highlighting then everything can be run immediately
        guard isAnimated && highlight else {
            self.tableView.scrollToRow(
                at: targetIndexPath,
                at: position,
                animated: (self.didFinishInitialLayout && isAnimated)
            )
            
            // If we haven't finished the initial layout then we want to delay the highlight slightly
            // so it doesn't look buggy with the push transition
            if highlight {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(self.didFinishInitialLayout ? 0 : 150)) { [weak self] in
                    self?.highlightCellIfNeeded(interactionId: interactionId)
                }
            }
            
            self.shouldHighlightNextScrollToInteraction = false
            self.focusedInteractionId = nil
            return
        }
        
        // If we are animating and highlighting then determine if we want to scroll to the target
        // cell (if we try to trigger the `scrollToRow` call and the animation doesn't occur then
        // the highlight will not be triggered so if a cell is entirely on the screen then just
        // don't bother scrolling)
        let targetRect: CGRect = self.tableView.rectForRow(at: targetIndexPath)
        
        guard !self.tableView.bounds.contains(targetRect) else {
            self.highlightCellIfNeeded(interactionId: interactionId)
            return
        }
        
        self.tableView.scrollToRow(at: targetIndexPath, at: position, animated: true)
    }
    
    func highlightCellIfNeeded(interactionId: Int64) {
        self.shouldHighlightNextScrollToInteraction = false
        self.focusedInteractionId = nil
        
        // Trigger on the next run loop incase we are still finishing some other animation
        DispatchQueue.main.async {
            self.tableView
                .visibleCells
                .first(where: { ($0 as? VisibleMessageCell)?.viewModel?.id == interactionId })
                .asType(VisibleMessageCell.self)?
                .highlight()
        }
    }
}