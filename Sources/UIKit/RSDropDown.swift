//
//  RSDropDown.swift
//  RSDropDown
//
//  Created by Radu Ursache (RanduSoft)
//

import UIKit

open class RSDropDown: UITextField {

    // MARK: - Configuration

    /// Grouped configuration for all dropdown appearance and behavior.
    public var configuration = DropDownConfiguration() {
        didSet { applyConfiguration() }
    }

    // MARK: - Public Properties

    /// The items displayed in the dropdown. Supports any `DropDownItem` conforming type.
    /// Setting this via `[String]` works automatically because `String` conforms to `DropDownItem`.
    public var optionArray: [String] = [] {
        didSet {
            tableManager.setItems(optionArray)
            if placeholder == nil && !optionArray.isEmpty {
                selectedIndex = 0
            }
        }
    }

    /// The currently selected index (in the unfiltered array).
    public var selectedIndex: Int? {
        didSet {
            if let index = selectedIndex, index >= 0, index < tableManager.allItems.count {
                text = tableManager.allItems[index].dropDownTitle
            } else {
                selectedIndex = nil
                text = nil
            }
            tableManager.selectedIndex = selectedIndex
        }
    }

    /// The title of the currently selected item, or empty string if none.
    public var selectedItemTitle: String {
        text ?? ""
    }

    /// Text insets for the text field.
    public var padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0) {
        didSet { layoutIfNeeded() }
    }

    override open var placeholder: String? {
        didSet {
            selectedIndex = nil
        }
    }

    // MARK: - Callbacks (v3 API)

    /// Called when the user selects an item.
    public var onSelection: ((DropDownSelection) -> Void)?

    /// Called just before the dropdown list appears.
    public var onDropDownWillAppear: (() -> Void)?

    /// Called after the dropdown list has fully appeared.
    public var onDropDownDidAppear: (() -> Void)?

    /// Called just before the dropdown list disappears.
    public var onDropDownWillDisappear: (() -> Void)?

    /// Called after the dropdown list has fully disappeared.
    public var onDropDownDidDisappear: (() -> Void)?

    // MARK: - Private State

    private var tableView: UITableView?
    private var chevronImageView: UIImageView!
    private var shadowView: UIView?
    private var backgroundView = UIView()
    private var tableManager = RSDropDownTableManager()
    private var animator = RSDropDownAnimator(duration: 0.25)
    private var selectionFeedback = UISelectionFeedbackGenerator()

    private var tableViewHeightY: CGFloat = 100
    private var pointToParent = CGPoint.zero
    private var keyboardHeight: CGFloat = 0
    public private(set) var isDropDownOpen: Bool = false
    private var willShowTableViewUp: Bool = false

    private var keyboardWillShowToken: Any?
    private var keyboardWillHideToken: Any?

    /// Glass effect background inserted behind the text field content (iOS 26+ or blur fallback).
    private var glassBackgroundView: UIView?

    // Legacy callback storage (used by deprecated API shims)
    var legacyDidSelectCompletion: ((String, Int, Int) -> Void)?
    var legacyTableViewWillAppearHandler: (() -> Void)?
    var legacyTableViewDidAppearHandler: (() -> Void)?
    var legacyTableViewWillDisappearHandler: (() -> Void)?
    var legacyTableViewDidDisappearHandler: (() -> Void)?

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        delegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        delegate = self
    }

    deinit {
        removeKeyboardObservers()
    }

    // MARK: - Public Methods

    /// Sets dropdown items from any `DropDownItem` conforming type.
    public func setItems(_ items: [any DropDownItem]) {
        tableManager.setItems(items)
        if placeholder == nil && !items.isEmpty {
            selectedIndex = 0
        }
    }

    /// Programmatically shows the dropdown list.
    public func showList() {
        guard let parentController = parentViewController else { return }

        let items = tableManager.filteredItems
        guard !items.isEmpty else {
            if !tableManager.allItems.isEmpty {
                tableManager.resetFilter()
                showList()
            }
            return
        }

        backgroundView.frame = parentController.view.frame
        backgroundView.backgroundColor = configuration.style.usesGlassEffect
            ? .clear
            : .black.withAlphaComponent(0.1)
        pointToParent = getConvertedPoint(for: self, relativeTo: parentController.view)
        parentController.view.insertSubview(backgroundView, aboveSubview: self)

        // Cut a hole in the scrim where the dropdown is so it stays fully visible
        if !configuration.style.usesGlassEffect {
            applyScrimMask()
        }

        onDropDownWillAppear?()
        legacyTableViewWillAppearHandler?()

        tableViewHeightY = min(
            configuration.list.maxHeight,
            configuration.style.rowHeight * CGFloat(items.count)
        )

        configureTableView(in: parentController)
        isDropDownOpen = true

        adjustTablePositionAccordingToKeyboardHeight(in: parentController)

        // Temporarily set the table to its full height so scrollToRow can
        // calculate the correct .middle offset, then the animator will
        // collapse it back to 0 and animate the expansion.
        if let tableView {
            tableView.frame.size.height = tableViewHeightY
            tableView.layoutIfNeeded()
            scrollToSelectedRowIfNeeded()
        }

        animateTablePresentation()
    }

    /// Programmatically hides the dropdown list.
    public func hideList() {
        guard let tableView, let shadowView, let chevronImageView else { return }

        onDropDownWillDisappear?()
        legacyTableViewWillDisappearHandler?()

        let collapseY = pointToParent.y + (!willShowTableViewUp ? frame.height : 0)

        animator.animateHide(
            tableView: tableView,
            shadowView: shadowView,
            chevronImageView: chevronImageView,
            collapseToY: collapseY,
            collapseWidth: frame.width,
            collapseX: pointToParent.x
        ) { [weak self] in
            self?.shadowView?.removeFromSuperview()
            self?.tableView?.removeFromSuperview()
            self?.backgroundView.removeFromSuperview()
            self?.isDropDownOpen = false
            self?.onDropDownDidDisappear?()
            self?.legacyTableViewDidDisappearHandler?()

            self?.accessibilityHint = NSLocalizedString("Double tap to show options", comment: "Dropdown hint")
            UIAccessibility.post(notification: .layoutChanged, argument: self)
        }
    }

    /// Toggles the dropdown open/close state.
    @objc public func touchAction() {
        isDropDownOpen ? hideList() : showList()
    }

    /// Dismisses the dropdown when tapping the background scrim.
    @objc public func backgroundTouchAction() {
        if configuration.search.isEnabled {
            if isDropDownOpen {
                hideList()
            }
        } else {
            touchAction()
        }
    }

    // MARK: - Chainable Configuration API

    @discardableResult
    public func rowHeight(_ height: CGFloat) -> Self {
        configuration.style.rowHeight = height
        return self
    }

    @discardableResult
    public func rowBackgroundColor(_ color: UIColor) -> Self {
        configuration.style.rowBackgroundColor = color
        return self
    }

    @discardableResult
    public func rowTextColor(_ color: UIColor) -> Self {
        configuration.style.rowTextColor = color
        return self
    }

    @discardableResult
    public func selectedRowColor(_ color: UIColor) -> Self {
        configuration.style.selectedRowColor = color
        return self
    }

    @discardableResult
    public func cellFont(_ font: UIFont) -> Self {
        configuration.style.cellFont = font
        return self
    }

    @discardableResult
    public func listMaxHeight(_ height: CGFloat) -> Self {
        configuration.list.maxHeight = height
        return self
    }

    @discardableResult
    public func listSpacing(_ spacing: CGFloat) -> Self {
        configuration.list.spacing = spacing
        return self
    }

    @discardableResult
    public func listWidth(_ width: CGFloat?) -> Self {
        configuration.list.width = width
        return self
    }

    @discardableResult
    public func searchEnabled(_ enabled: Bool) -> Self {
        configuration.search.isEnabled = enabled
        return self
    }

    // MARK: - Text Rect Overrides

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    // MARK: - Private Setup

    private func setupUI() {
        let size = frame.height
        configureRightView(with: size)
        configureBackgroundView()
        updateKeyboardObservers()
        addGestures()

        addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingChanged)

        // Default text field appearance: rounded border like a standard UITextField
        layer.cornerCurve = .continuous
        layer.cornerRadius = configuration.style.cornerRadius
        layer.borderColor = configuration.style.borderColor.cgColor
        layer.borderWidth = 1
        backgroundColor = configuration.style.rowBackgroundColor
        clipsToBounds = true

        // Accessibility
        accessibilityTraits = .button
        accessibilityHint = NSLocalizedString("Double tap to show options", comment: "Dropdown hint")

        // Table manager callback
        tableManager.onItemSelected = { [weak self] item, originalIndex in
            self?.handleSelection(item: item, index: originalIndex)
        }

        tableManager.onDataChanged = { [weak self] in
            self?.reloadTableData()
            self?.resizeTable()
        }
    }

    private func applyConfiguration() {
        // Glass / standard appearance
        applyGlassEffectIfNeeded()

        animator.duration = configuration.animation.duration
        tableManager.style = configuration.style
        tableManager.showCheckmark = configuration.behavior.showCheckmark
        tableManager.isSearchEnabled = configuration.search.isEnabled

        // Update chevron appearance
        chevronImageView?.tintColor = configuration.chevron.color
        chevronImageView?.image = configuration.chevron.image
        updateChevronSize()

        // Update keyboard observers for search mode changes
        updateKeyboardObservers()
        addGestures()
    }

    private func configureRightView(with size: CGFloat) {
        let containerSize = max(size, 44)
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: containerSize, height: containerSize))
        rightViewMode = .always

        guard let rightView else { return }

        let chevronContainerView = UIView(frame: rightView.bounds)
        rightView.addSubview(chevronContainerView)
        setupChevron(in: chevronContainerView)

        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(touchAction))
        rightView.addGestureRecognizer(touchGesture)
    }

    private func setupChevron(in containerView: UIView) {
        let chevronSize = configuration.chevron.size
        let containerCenter = containerView.center
        chevronImageView = UIImageView(frame: CGRect(
            x: containerCenter.x - chevronSize / 2,
            y: containerCenter.y - chevronSize / 2,
            width: chevronSize,
            height: chevronSize
        ))
        chevronImageView.image = configuration.chevron.image
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.tintColor = configuration.chevron.color
        containerView.addSubview(chevronImageView)
    }

    private func updateChevronSize() {
        guard let chevronImageView, let container = chevronImageView.superview else { return }
        let size = configuration.chevron.size
        let center = container.center
        chevronImageView.frame = CGRect(
            x: center.x - size / 2,
            y: center.y - size / 2,
            width: size,
            height: size
        )
    }

    private func configureBackgroundView() {
        backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = .black.withAlphaComponent(0.1)
    }

    // MARK: - Keyboard Observers

    private func updateKeyboardObservers() {
        removeKeyboardObservers()
        guard configuration.search.isEnabled, configuration.behavior.handleKeyboard else { return }

        keyboardWillShowToken = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self, self.isFirstResponder else { return }
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                self.keyboardHeight = keyboardFrame.cgRectValue.height
            }
            if !self.isDropDownOpen {
                self.showList()
            }
        }

        keyboardWillHideToken = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self, self.isFirstResponder else { return }
            self.keyboardHeight = 0
        }
    }

    private func removeKeyboardObservers() {
        if let token = keyboardWillShowToken {
            NotificationCenter.default.removeObserver(token)
            keyboardWillShowToken = nil
        }
        if let token = keyboardWillHideToken {
            NotificationCenter.default.removeObserver(token)
            keyboardWillHideToken = nil
        }
    }

    // MARK: - Gestures

    private func addGestures() {
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
        backgroundView.gestureRecognizers?.forEach { backgroundView.removeGestureRecognizer($0) }

        if !configuration.search.isEnabled {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchAction))
            addGestureRecognizer(tapGesture)
        }

        let backgroundGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTouchAction))
        backgroundView.addGestureRecognizer(backgroundGesture)
    }

    // MARK: - Table View Configuration

    private func configureTableView(in parentController: UIViewController) {
        let listWidth = configuration.list.width
        let tableX: CGFloat
        let tableWidth: CGFloat

        if let listWidth {
            tableX = pointToParent.x + (frame.width / 2) - (listWidth / 2)
            tableWidth = listWidth
        } else {
            tableX = pointToParent.x
            tableWidth = frame.width
        }

        let tv = UITableView(frame: CGRect(
            x: tableX,
            y: 0,
            width: tableWidth,
            height: frame.height
        ))

        tv.register(RSDropDownCell.self, forCellReuseIdentifier: RSDropDownCell.reuseIdentifier)
        tv.dataSource = tableManager
        tv.delegate = tableManager
        tv.alpha = 0
        tv.separatorStyle = configuration.style.showSeparators ? .singleLine : .none
        tv.layer.cornerRadius = configuration.style.cornerRadius
        tv.layer.cornerCurve = .continuous
        tv.backgroundColor = configuration.style.rowBackgroundColor
        tv.rowHeight = configuration.style.rowHeight
        tv.clipsToBounds = true
        tv.showsVerticalScrollIndicator = true
        tv.verticalScrollIndicatorInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)

        if configuration.style.usesGlassEffect {
            tv.backgroundView = makeGlassTableBackground()
            tv.backgroundColor = .clear
        } else if configuration.style.showBorder {
            tv.layer.borderColor = configuration.style.borderColor.cgColor
            tv.layer.borderWidth = configuration.style.borderWidth > 0 ? configuration.style.borderWidth : 1
        }

        let sv = UIView(frame: tv.frame)
        sv.backgroundColor = .clear
        sv.layer.cornerRadius = configuration.style.cornerRadius
        sv.layer.cornerCurve = .continuous

        if configuration.style.showShadow {
            sv.layer.shadowColor = UIColor.black.cgColor
            sv.layer.shadowOpacity = 0.15
            sv.layer.shadowRadius = 8
            sv.layer.shadowOffset = CGSize(width: 0, height: 2)
        }

        tableView = tv
        shadowView = sv

        parentController.view.addSubview(sv)
        parentController.view.addSubview(tv)
    }

    private func adjustTablePositionAccordingToKeyboardHeight(in parentController: UIViewController) {
        let availableHeight = parentController.view.frame.height - (pointToParent.y + frame.height + configuration.list.spacing)
        var yPosition = pointToParent.y + frame.height + configuration.list.spacing

        if availableHeight < (keyboardHeight + tableViewHeightY) {
            yPosition = pointToParent.y - tableViewHeightY - configuration.list.spacing
            willShowTableViewUp = true
        } else {
            willShowTableViewUp = false
        }

        tableView?.frame.origin.y = yPosition
    }

    private func animateTablePresentation() {
        guard let tableView, let shadowView, let chevronImageView else { return }

        let targetY = tableView.frame.origin.y

        animator.animateShow(
            tableView: tableView,
            shadowView: shadowView,
            chevronImageView: chevronImageView,
            targetHeight: tableViewHeightY,
            targetY: targetY,
            showShadow: configuration.style.showShadow,
            willShowUp: willShowTableViewUp,
            dropDownOriginY: pointToParent.y
        ) { [weak self] in
            self?.layoutIfNeeded()
            self?.flashScrollIndicatorsIfNeeded()

            self?.onDropDownDidAppear?()
            self?.legacyTableViewDidAppearHandler?()

            self?.accessibilityHint = NSLocalizedString("Double tap to dismiss", comment: "Dropdown hint")
            UIAccessibility.post(notification: .layoutChanged, argument: self?.tableView)
        }
    }

    // MARK: - Scrim Mask

    private func applyScrimMask() {
        let dropdownRect = CGRect(
            x: pointToParent.x,
            y: pointToParent.y,
            width: frame.width,
            height: frame.height
        )

        let fullPath = UIBezierPath(rect: backgroundView.bounds)
        let holePath = UIBezierPath(
            roundedRect: dropdownRect,
            cornerRadius: configuration.style.cornerRadius
        )
        fullPath.append(holePath)
        fullPath.usesEvenOddFillRule = true

        let mask = CAShapeLayer()
        mask.path = fullPath.cgPath
        mask.fillRule = .evenOdd
        backgroundView.layer.mask = mask
    }

    // MARK: - Liquid Glass

    private func applyGlassEffectIfNeeded() {
        // Remove any existing glass background
        glassBackgroundView?.removeFromSuperview()
        glassBackgroundView = nil

        // Always keep corner radius in sync
        layer.cornerRadius = configuration.style.cornerRadius
        layer.cornerCurve = .continuous

        guard configuration.style.usesGlassEffect else {
            // Restore standard opaque appearance
            backgroundColor = configuration.style.rowBackgroundColor
            layer.borderColor = configuration.style.borderColor.cgColor
            layer.borderWidth = configuration.style.showBorder
                ? (configuration.style.borderWidth > 0 ? configuration.style.borderWidth : 1)
                : 0
            clipsToBounds = true
            return
        }

        // Glass mode: transparent text field with glass material behind it
        let effectView: UIVisualEffectView
        if #available(iOS 26, *) {
            effectView = UIVisualEffectView(effect: UIGlassEffect())
        } else {
            effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        }

        effectView.frame = bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.layer.cornerRadius = configuration.style.cornerRadius
        effectView.layer.cornerCurve = .continuous
        effectView.clipsToBounds = true
        effectView.isUserInteractionEnabled = false
        insertSubview(effectView, at: 0)

        backgroundColor = .clear
        layer.borderWidth = 0
        clipsToBounds = true

        glassBackgroundView = effectView
    }

    private func makeGlassTableBackground() -> UIVisualEffectView {
        let effectView: UIVisualEffectView
        if #available(iOS 26, *) {
            effectView = UIVisualEffectView(effect: UIGlassEffect())
        } else {
            effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        }
        return effectView
    }

    // MARK: - Helpers

    private func flashScrollIndicatorsIfNeeded() {
        guard let tableView else { return }
        // Delay slightly so the table is fully visible before flashing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            tableView.flashScrollIndicators()
        }
    }

    private func scrollToSelectedRowIfNeeded() {
        guard configuration.behavior.scrollToSelection,
              let selectedIndex,
              selectedIndex >= 0,
              selectedIndex < tableManager.filteredItems.count,
              let tableView else { return }
        tableView.scrollToRow(at: IndexPath(row: selectedIndex, section: 0), at: .middle, animated: false)
    }

    func resizeTable() {
        guard let tableView, let shadowView else { return }

        tableViewHeightY = min(
            configuration.list.maxHeight,
            configuration.style.rowHeight * CGFloat(tableManager.filteredItems.count)
        )

        guard let parentController = parentViewController else { return }
        let availableHeight = parentController.view.frame.height - (pointToParent.y + frame.height + configuration.list.spacing)
        var yPosition = pointToParent.y + frame.height + configuration.list.spacing

        if availableHeight < (keyboardHeight + tableViewHeightY) {
            yPosition = pointToParent.y - tableViewHeightY
        }

        let tableX: CGFloat
        let tableWidth: CGFloat
        if let listWidth = configuration.list.width {
            tableX = pointToParent.x + (frame.width / 2) - (listWidth / 2)
            tableWidth = listWidth
        } else {
            tableX = pointToParent.x
            tableWidth = frame.width
        }

        UIView.animate(withDuration: configuration.animation.duration * 0.5) {
            tableView.frame = CGRect(
                x: tableX,
                y: yPosition,
                width: tableWidth,
                height: self.tableViewHeightY
            )
            shadowView.frame = tableView.frame
        }
    }

    private func reloadTableData() {
        guard let tableView else { return }
        DispatchQueue.main.async {
            tableView.reloadData()
        }
    }

    private func handleSelection(item: any DropDownItem, index: Int) {
        selectedIndex = index

        // Haptic feedback
        if configuration.behavior.hapticFeedback {
            selectionFeedback.selectionChanged()
        }

        // Fire callbacks
        let selection = DropDownSelection(item: item, index: index)
        onSelection?(selection)

        // Legacy callback support
        let legacyId = (item.dropDownID as? Int) ?? 0
        legacyDidSelectCompletion?(item.dropDownTitle, index, legacyId)

        if configuration.behavior.hideOnSelect {
            touchAction()
            endEditing(true)
        }

        reloadTableData()
    }

    func getConvertedPoint(for targetView: UIView, relativeTo baseView: UIView?) -> CGPoint {
        var point = targetView.frame.origin
        guard var currentSuperView = targetView.superview else {
            return point
        }

        while currentSuperView != baseView {
            point = currentSuperView.convert(point, to: currentSuperView.superview)
            guard let nextSuperview = currentSuperView.superview else { break }
            currentSuperView = nextSuperview
        }

        return currentSuperView.convert(point, to: baseView)
    }
}

// MARK: - UITextFieldDelegate

extension RSDropDown: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        superview?.endEditing(true)
        return false
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if configuration.search.clearSelectionOnOpen {
            selectedIndex = nil
        }
        tableManager.resetFilter()
        touchAction()
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        configuration.search.isEnabled
    }

    @objc private func textFieldTextChanged(_ textField: UITextField) {
        let searchText = textField.text ?? ""
        tableManager.filterItems(with: searchText)

        if !isDropDownOpen {
            showList()
        }
    }
}
