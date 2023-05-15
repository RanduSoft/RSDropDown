//
//  RSDropDown
//
//  Created by Radu Ursache.
//
//  v2.0

import UIKit

open class RSDropDown: UITextField {
    fileprivate var tableView: UITableView!
    fileprivate var chevronImageView: UIImageView!
    fileprivate var shadowView: UIView!
    fileprivate var tableViewHeightX: CGFloat = 100
    fileprivate var dataArray = [String]()
    fileprivate var imageArray = [String]()
    fileprivate weak var parentController: UIViewController?
    fileprivate var pointToParent = CGPoint.zero
    fileprivate var backgroundView = UIView()
    fileprivate var keyboardHeight: CGFloat = 0
    fileprivate var searchText = String() {
        didSet {
            self.dataArray = self.searchText.isEmpty ? self.optionArray : self.optionArray.filter {
                $0.range(of: self.searchText, options: .caseInsensitive) != nil
            }
            
            self.resizeTable()
            self.selectedIndex = nil
            self.reloadData()
        }
    }
    
    fileprivate var didSelectCompletion: ((String, Int, Int) -> Void) = { _, _, _ in }
    fileprivate var tableViewWillAppearHandler: (() -> Void) = {}
    fileprivate var tableViewDidAppearHandler: (() -> Void) = {}
    fileprivate var tableViewWillDisappearHandler: (() -> Void) = {}
    fileprivate var tableViewDidDisappearHandler: (() -> Void) = {}
    
    @IBInspectable public var rowHeight: CGFloat = 40
    @IBInspectable public var animationDuration: TimeInterval = 0.3
    @IBInspectable public var rowBackgroundColor: UIColor = .systemGray6
    @IBInspectable public var rowTextColor: UIColor = .label
    @IBInspectable public var selectedRowColor: UIColor = .clear
    @IBInspectable public var hideOptionsOnSelect = true
    @IBInspectable public var checkMarkEnabled: Bool = true
    @IBInspectable public var handleKeyboard: Bool = true
    @IBInspectable public var flashIndicatorWhenOpeningList: Bool = true
    @IBInspectable public var scrollToSelectedItem: Bool = true
    @IBInspectable public var imageCellIsRounded: Bool = false
    @IBInspectable public var showTableBorder: Bool = false
    @IBInspectable public var tableViewCornerRadius: CGFloat = 8
    @IBInspectable public var listHeight: CGFloat = 150
    @IBInspectable public var borderColor: UIColor = .systemGray6 {
        didSet { self.layer.borderColor = self.borderColor.cgColor }
    }
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = self.borderWidth }
    }
    @IBInspectable public var padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0) {
        didSet { self.layoutIfNeeded() }
    }
    @IBInspectable public var chevronSize: CGFloat = 15 {
        didSet {
            let center = self.chevronImageView.superview!.center ; let size = self.chevronSize
            self.chevronImageView.frame = CGRect(x: center.x - size / 2, y: center.y - size / 2, width: size, height: size)
        }
    }
    @IBInspectable public var chevronColor: UIColor = .label {
        didSet { self.chevronImageView.tintColor = self.chevronColor }
    }
    @IBInspectable public var chevronImage: UIImage = UIImage(systemName: "chevron.down")! {
        didSet { self.chevronImageView.image = self.chevronImage }
    }
    @IBInspectable public var isSearchEnable: Bool = false {
        didSet { self.addGestures() }
    }
    @IBInspectable public var tableViewCellFont: UIFont = .systemFont(ofSize: 17)
    
    public var selectedIndex: Int? {
        didSet {
            if let selectedIndex = self.selectedIndex {
                self.text = self.optionArray[selectedIndex]
            } else {
                self.text = nil
            }
        }
    }
    
    public var optionArray = [String]() {
        didSet {
            self.dataArray = self.optionArray
            
            if self.placeholder == nil {
                self.selectedIndex = 0
            }
        }
    }
    
    public var optionImageArray = [String]() {
        didSet { self.imageArray = self.optionImageArray }
    }
    
    public var optionIds: [Int]?
    
    public var selectedItemTitle: String {
        return self.text ?? ""
    }
    
    override open var placeholder: String? {
        didSet {
            self.selectedIndex = nil
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
        self.delegate = self
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.setupUI()
        self.delegate = self
    }

    private func setupUI() {
        let size = self.frame.height
        
        self.configureRightView(with: size)
        self.configureBackgroundView()
        self.observeKeyboardNotifications()
        self.addGestures()
    }

    private func configureRightView(with size: CGFloat) {
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        self.rightView = rightView
        self.rightViewMode = .always
        let chevronContainerView = UIView(frame: rightView.frame)
        self.rightView?.addSubview(chevronContainerView)
        self.setupChevron(in: chevronContainerView)
    }

    private func setupChevron(in containerView: UIView) {
        let containerCenter = containerView.center
        self.chevronImageView = UIImageView(frame: CGRect(x: containerCenter.x - self.chevronSize/2, y: containerCenter.y - self.chevronSize/2, width: self.chevronSize, height: self.chevronSize))
        self.chevronImageView.image = self.chevronImage
        self.chevronImageView.contentMode = .scaleAspectFit
        self.chevronImageView.tintColor = self.chevronColor
        containerView.addSubview(self.chevronImageView)
    }

    private func configureBackgroundView() {
        self.backgroundView = UIView(frame: .zero)
        self.backgroundView.backgroundColor = .clear
    }

    private func observeKeyboardNotifications() {
        guard self.isSearchEnable, self.handleKeyboard else { return }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            if self.isFirstResponder {
                let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                self.keyboardHeight = keyboardFrame.height
                if !self.isSelected {
                    self.showList()
                }
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            if self.isFirstResponder {
                self.keyboardHeight = 0
            }
        }
    }

    private func addGestures() {
        let touchActionGesture = UITapGestureRecognizer(target: self, action: #selector(self.touchAction))
        if self.isSearchEnable {
            self.rightView?.addGestureRecognizer(touchActionGesture)
        } else {
            self.addGestureRecognizer(touchActionGesture)
        }

        let backgroundViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.touchAction))
        self.backgroundView.addGestureRecognizer(backgroundViewGesture)
    }
    
    public func showList() {
        guard let parentController = self.parentViewController else { return }
        guard self.dataArray.count > 0 else {
            print("[RSDropDown] ⚠️ optionArray is empty, the table can't be build") ; return
        }

        self.backgroundView.frame = parentController.view.frame
        self.pointToParent = self.getConvertedPoint(for: self, relativeTo: parentController.view)
        parentController.view.insertSubview(self.backgroundView, aboveSubview: self)

        self.tableViewWillAppearHandler()
        self.tableViewHeightX = min(self.listHeight, self.rowHeight * CGFloat(self.dataArray.count))
        self.configureTableView(in: parentController)
        
        self.isSelected = true
        
        self.adjustTablePositionAccordingToKeyboardHeight(in: parentController)
        self.animateTablePresentation()
    }

    private func configureTableView(in parentController: UIViewController) {
        self.tableView = UITableView(frame: CGRect(x: self.pointToParent.x, y: self.pointToParent.y + self.frame.height, width: self.frame.width, height: self.frame.height))
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.alpha = 0
        self.tableView.separatorStyle = .singleLine
        self.tableView.layer.cornerRadius = self.tableViewCornerRadius
        self.tableView.backgroundColor = self.rowBackgroundColor
        self.tableView.rowHeight = self.rowHeight

        self.configureTableBorder()

        self.shadowView = UIView(frame: self.tableView.frame)
        self.shadowView.backgroundColor = .clear

        parentController.view.addSubview(self.shadowView)
        parentController.view.addSubview(self.tableView)
    }

    private func configureTableBorder() {
        if self.showTableBorder {
            self.tableView.layer.borderColor = self.borderColor.cgColor
            self.tableView.layer.borderWidth = self.borderWidth > 0 ? self.borderWidth : 1
        }
    }

    private func adjustTablePositionAccordingToKeyboardHeight(in parentController: UIViewController) {
        let availableHeight = (parentController.view.frame.height) - (self.pointToParent.y + self.frame.height + 5)
        var yPosition = self.pointToParent.y + self.frame.height + 5

        if availableHeight < (self.keyboardHeight + self.tableViewHeightX) {
            yPosition = self.pointToParent.y - self.tableViewHeightX
        }

        self.tableView.frame.origin.y = yPosition
    }

    private func animateTablePresentation() {
        UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseInOut) {
            self.tableView.frame.size.height = self.tableViewHeightX
            self.tableView.alpha = 1
            self.shadowView.frame = self.tableView.frame
            self.chevronImageView.transform = CGAffineTransform(rotationAngle: .pi)
        } completion: { [weak self] _ in
            self?.layoutIfNeeded()
            self?.flashScrollIndicatorsIfNeeded()
            self?.scrollToSelectedRowIfNeeded()
            self?.tableViewDidAppearHandler()
        }
    }

    private func flashScrollIndicatorsIfNeeded() {
        if self.flashIndicatorWhenOpeningList {
            DispatchQueue.main.async {
                self.tableView.flashScrollIndicators()
            }
        }
    }

    private func scrollToSelectedRowIfNeeded() {
        if self.scrollToSelectedItem, let selectedIndex = self.selectedIndex {
            self.tableView.scrollToRow(at: IndexPath(row: selectedIndex, section: 0), at: .middle, animated: true)
        }
    }

    public func hideList() {
        self.tableViewWillDisappearHandler()
        
        UIView.animate(withDuration: self.animationDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
            self.tableView.frame = CGRect(x: self.pointToParent.x, y: self.pointToParent.y + self.frame.height, width: self.frame.width, height: 0)
            self.shadowView.alpha = 0
            self.shadowView.frame = self.tableView.frame
            self.chevronImageView.transform = CGAffineTransform.identity
        } completion: { [weak self] _ in
            self?.shadowView.removeFromSuperview()
            self?.tableView.removeFromSuperview()
            self?.backgroundView.removeFromSuperview()
            self?.isSelected = false
            self?.tableViewDidDisappearHandler()
        }
    }

    @objc public func touchAction() {
        self.isSelected ? self.hideList() : self.showList()
    }

    func resizeTable() {
        self.tableViewHeightX = min(self.listHeight, self.rowHeight * CGFloat(self.dataArray.count))
        let availableHeight = (self.parentController?.view.frame.height ?? 0) - (self.pointToParent.y + frame.height + 5)
        var yPosition = self.pointToParent.y + frame.height + 5

        if availableHeight < (self.keyboardHeight + self.tableViewHeightX) {
            yPosition = self.pointToParent.y - self.tableViewHeightX
        }

        UIView.animate(withDuration: self.animationDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
            self.tableView.frame = CGRect(x: self.pointToParent.x, y: yPosition, width: self.frame.width, height: self.tableViewHeightX)
            self.shadowView.frame = self.tableView.frame
        } completion: { [weak self] _ in
            self?.layoutIfNeeded()
        }
    }

	public func didSelect(completion: @escaping (_ selectedText: String, _ index: Int , _ id:Int ) -> ()) {
        self.didSelectCompletion = completion
	}

	public func listWillAppear(completion: @escaping () -> ()) {
        self.tableViewWillAppearHandler = completion
	}

	public func listDidAppear(completion: @escaping () -> ()) {
        self.tableViewDidAppearHandler = completion
	}

	public func listWillDisappear(completion: @escaping () -> ()) {
        self.tableViewWillDisappearHandler = completion
	}

	public func listDidDisappear(completion: @escaping () -> ()) {
        self.tableViewDidDisappearHandler = completion
	}

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// textfield delegate
extension RSDropDown: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.superview?.endEditing(true)
        return false
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.text = ""
        self.dataArray = self.optionArray
        self.touchAction()
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self.isSearchEnable
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.searchText = string.isEmpty ? String(text!.dropLast()) : text! + string
        if !self.isSelected {
            self.showList()
        }
        return true
    }
}

// tableview delegate
extension RSDropDown: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DropDownCell")
        cell.backgroundColor = indexPath.row != self.selectedIndex ? self.rowBackgroundColor : self.selectedRowColor

        if self.imageArray.indices.contains(indexPath.row) {
            let imageViewScale: CGFloat = 0.75
            cell.imageView?.image = self.resize(image: UIImage(named: self.imageArray[indexPath.row])!, to: CGSize(width: self.rowHeight * imageViewScale, height: self.rowHeight * imageViewScale))
            cell.imageView?.contentMode = .center
            cell.imageView?.clipsToBounds = true
            cell.imageView?.layer.cornerRadius = self.imageCellIsRounded ? (self.rowHeight * imageViewScale) / 2 : 0
        }

        cell.textLabel?.text = "\(self.dataArray[indexPath.row])"
        cell.textLabel?.textColor = self.rowTextColor
        cell.accessoryType = (indexPath.row == self.selectedIndex) && self.checkMarkEnabled ? .checkmark : .none
        cell.selectionStyle = .none
        cell.tintColor = cell.textLabel?.textColor ?? .label
        cell.textLabel?.font = self.tableViewCellFont
        cell.textLabel?.textAlignment = textAlignment
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        let selectedText = self.dataArray[selectedIndex!]
        tableView.cellForRow(at: indexPath)?.alpha = 0

        UIView.animate(withDuration: 0.3, animations: {
            tableView.cellForRow(at: indexPath)?.alpha = 1.0
            tableView.cellForRow(at: indexPath)?.backgroundColor = self.selectedRowColor
        }) { [weak self] _ in
            self?.text = "\(selectedText)"
            self?.reloadData()
        }

        if self.hideOptionsOnSelect {
            self.touchAction()
            self.endEditing(true)
        }

        if let selected = self.optionArray.firstIndex(where: { $0 == selectedText }) {
            self.didSelectCompletion(selectedText, selected, self.optionIds?[selected] ?? 0)
        }
    }
}

// extensions
fileprivate extension UIView {
	var parentViewController: UIViewController? {
		var parentResponder: UIResponder? = self
		while parentResponder != nil {
			parentResponder = parentResponder!.next
			if let viewController = parentResponder as? UIViewController {
				return viewController
			}
		}
		return nil
	}
}

// helpers
fileprivate extension RSDropDown {
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getConvertedPoint(for targetView: UIView, relativeTo baseView: UIView?) -> CGPoint {
        var point = targetView.frame.origin
        guard let superView = targetView.superview else {
            return point
        }

        var currentSuperView = superView
        while currentSuperView != baseView {
            point = currentSuperView.convert(point, to: currentSuperView.superview)
            if currentSuperView.superview == nil {
                break
            } else {
                currentSuperView = currentSuperView.superview!
            }
        }

        return currentSuperView.convert(point, to: baseView)
    }
    
    func resize(image: UIImage, to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
