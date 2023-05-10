//
//  RSDropDown
//
//  Created by Radu Ursache.
//
//

import UIKit

open class RSDropDown: UITextField {

    fileprivate var arrow: Arrow!
	public var table: UITableView!
	public var shadow: UIView!
	public var selectedIndex: Int? {
		didSet {
			guard let selectedIndex = self.selectedIndex else { return }
			self.text = self.optionArray[selectedIndex]
		}
	}

	//MARK: IBInspectable
	@IBInspectable public var rowHeight: CGFloat = 40
	@IBInspectable public var animationDuration: TimeInterval = 0.3
	@IBInspectable public var rowBackgroundColor: UIColor = .systemGray6
	@IBInspectable public var selectedRowColor: UIColor = .clear
	@IBInspectable public var hideOptionsWhenSelect = true
	@IBInspectable public var checkMarkEnabled: Bool = true
	@IBInspectable public var handleKeyboard: Bool = true
	@IBInspectable public var flashIndicatorWhenOpeningList: Bool = true
	@IBInspectable public var scrollToSelectedItem: Bool = true
	@IBInspectable public var imageCellIsRounded: Bool = false
	@IBInspectable public var showTableBorder: Bool = false
	@IBInspectable public var listHeight: CGFloat = 150
	
	@IBInspectable public var isSearchEnable: Bool = false {
		didSet {
			addGesture()
		}
	}
	
	@IBInspectable public var arrowSize: CGFloat = 15 {
		didSet{
			let center =  arrow.superview!.center
			arrow.frame = CGRect(x: center.x - arrowSize/2, y: center.y - arrowSize/2, width: arrowSize, height: arrowSize)
		}
	}
	@IBInspectable public var arrowColor: UIColor = .label {
		didSet{
			arrow.arrowColor = arrowColor
		}
	}

	@IBInspectable public var borderColor: UIColor = .systemGray6 {
		didSet {
			layer.borderColor = borderColor.cgColor
		}
	}
	@IBInspectable public var borderWidth: CGFloat = 0.0 {
		didSet {
			layer.borderWidth = borderWidth
		}
	}

	//Variables
	fileprivate var tableheightX: CGFloat = 100
	fileprivate var dataArray = [String]()
	fileprivate var imageArray = [String]()
	fileprivate weak var parentController: UIViewController?
	fileprivate var pointToParent = CGPoint(x: 0, y: 0)
	fileprivate var backgroundView = UIView()
	fileprivate var keyboardHeight: CGFloat = 0

	public var optionArray = [String]() {
		didSet{
			self.dataArray = self.optionArray
			self.selectedIndex = 0
		}
	}
	public var optionImageArray = [String]() {
		didSet{
			self.imageArray = self.optionImageArray
		}
	}
	public var optionIds : [Int]?
	
	public var tableCellFont: UIFont = .systemFont(ofSize: 17)
	
	var searchText = String() {
		didSet{
			if searchText == "" {
				self.dataArray = self.optionArray
			}else{
				self.dataArray = optionArray.filter {
					return $0.range(of: searchText, options: .caseInsensitive) != nil
				}
			}
			reSizeTable()
			selectedIndex = nil
			self.table.reloadData()
		}
	}
	
	public var selectedItemTitle: String {
		return self.text ?? ""
	}

	// Init
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		self.delegate = self
	}

	public required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
		setupUI()
		self.delegate = self
	}


	//MARK: Closures
	fileprivate var didSelectCompletion: (String, Int ,Int) -> () = {selectedText, index , id  in }
	fileprivate var TableWillAppearCompletion: () -> () = { }
	fileprivate var TableDidAppearCompletion: () -> () = { }
	fileprivate var TableWillDisappearCompletion: () -> () = { }
	fileprivate var TableDidDisappearCompletion: () -> () = { }

	func setupUI () {
		let size = self.frame.height
		let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: size))
		self.leftView = paddingView
		self.leftViewMode = .always
		let rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size, height: size))
		self.rightView = rightView
		self.rightViewMode = .always
		let arrowContainerView = UIView(frame: rightView.frame)
		self.rightView?.addSubview(arrowContainerView)
		let center = arrowContainerView.center
		arrow = Arrow(origin: CGPoint(x: center.x - arrowSize/2,y: center.y - arrowSize/2),size: arrowSize  )
		arrowContainerView.addSubview(arrow)

		self.backgroundView = UIView(frame: .zero)
		self.backgroundView.backgroundColor = .clear
		addGesture()
		if isSearchEnable && handleKeyboard{
			NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
				if self.isFirstResponder{
				let userInfo:NSDictionary = notification.userInfo! as NSDictionary
					let keyboardFrame:NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
				let keyboardRectangle = keyboardFrame.cgRectValue
				self.keyboardHeight = keyboardRectangle.height
					if !self.isSelected{
						self.showList()
					}
				}
			  
			}
			NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
				if self.isFirstResponder{
				self.keyboardHeight = 0
				}
			}
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	
	fileprivate func addGesture() {
		let gesture =  UITapGestureRecognizer(target: self, action:  #selector(touchAction))
		if isSearchEnable {
			self.rightView?.addGestureRecognizer(gesture)
		} else {
			self.addGestureRecognizer(gesture)
		}
		let gesture2 =  UITapGestureRecognizer(target: self, action:  #selector(touchAction))
		self.backgroundView.addGestureRecognizer(gesture2)
	}
	func getConvertedPoint(_ targetView: UIView, baseView: UIView?) -> CGPoint {
		var pnt = targetView.frame.origin
		if nil == targetView.superview{
			return pnt
		}
		var superView = targetView.superview
		while superView != baseView{
			pnt = superView!.convert(pnt, to: superView!.superview)
			if nil == superView!.superview{
				break
			} else {
				superView = superView!.superview
			}
		}
		return superView!.convert(pnt, to: baseView)
	}
	public func showList() {
		if parentController == nil {
			parentController = self.parentViewController
		}
		backgroundView.frame = parentController?.view.frame ?? backgroundView.frame
		pointToParent = getConvertedPoint(self, baseView: parentController?.view)
		parentController?.view.insertSubview(backgroundView, aboveSubview: self)
		TableWillAppearCompletion()
		if listHeight > rowHeight * CGFloat( dataArray.count) {
			self.tableheightX = rowHeight * CGFloat(dataArray.count)
		} else {
			self.tableheightX = listHeight
		}
		table = UITableView(frame: CGRect(x: pointToParent.x ,
										  y: pointToParent.y + self.frame.height ,
										  width: self.frame.width,
										  height: self.frame.height))
		shadow = UIView(frame: table.frame)
		shadow.backgroundColor = .clear

		table.dataSource = self
		table.delegate = self
		table.alpha = 0
		table.separatorStyle = .singleLine
        table.layer.cornerRadius = self.layer.cornerRadius
		
		if self.showTableBorder {
			table.layer.borderColor = self.borderColor.cgColor
			table.layer.borderWidth = self.borderWidth > 0 ? self.borderWidth : 1
		}
		
		table.backgroundColor = rowBackgroundColor
		table.rowHeight = rowHeight
		parentController?.view.addSubview(shadow)
		parentController?.view.addSubview(table)
		self.isSelected = true
		let height = (self.parentController?.view.frame.height ?? 0) - (self.pointToParent.y + self.frame.height + 5)
		var y = self.pointToParent.y+self.frame.height+5
		if height < (keyboardHeight+tableheightX){
			y = self.pointToParent.y - tableheightX
		}
		
		UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseInOut) {
			self.table.frame = CGRect(x: self.pointToParent.x,
									  y: y,
									  width: self.frame.width,
									  height: self.tableheightX)
			self.table.alpha = 1
			self.shadow.frame = self.table.frame
//			self.shadow.dropShadow()
			self.arrow.position = .up
		} completion: { finished in
			self.layoutIfNeeded()
			
			if self.flashIndicatorWhenOpeningList {
				DispatchQueue.main.async {
					self.table.flashScrollIndicators()
				}
			}
			if self.scrollToSelectedItem {
				if let selectedIndex = self.selectedIndex {
					self.table.scrollToRow(at: IndexPath(row: selectedIndex, section: 0), at: .middle, animated: true)
				}
			}
			
			self.TableDidAppearCompletion()
		}
	}


	public func hideList() {
		TableWillDisappearCompletion()
		UIView.animate(withDuration: self.animationDuration, delay: 0,
					   usingSpringWithDamping: 0.9,
					   initialSpringVelocity: 0.1,
					   options: .curveEaseInOut,
					   animations: { () -> Void in
						self.table.frame = CGRect(x: self.pointToParent.x,
												  y: self.pointToParent.y+self.frame.height,
												  width: self.frame.width,
												  height: 0)
						self.shadow.alpha = 0
						self.shadow.frame = self.table.frame
						self.arrow.position = .down
		},
					   completion: { (didFinish) -> Void in

						self.shadow.removeFromSuperview()
						self.table.removeFromSuperview()
						self.backgroundView.removeFromSuperview()
						self.isSelected = false
						self.TableDidDisappearCompletion()
		})
	}

	@objc public func touchAction() {

		isSelected ?  hideList() : showList()
	}
	func reSizeTable() {
		if listHeight > rowHeight * CGFloat( dataArray.count) {
			self.tableheightX = rowHeight * CGFloat(dataArray.count)
		}else{
			self.tableheightX = listHeight
		}
		let height = (self.parentController?.view.frame.height ?? 0) - (self.pointToParent.y + self.frame.height + 5)
		var y = self.pointToParent.y+self.frame.height+5
		if height < (keyboardHeight+tableheightX){
			y = self.pointToParent.y - tableheightX
		}
		UIView.animate(withDuration: self.animationDuration,
					   delay: 0,
					   usingSpringWithDamping: 0.9,
					   initialSpringVelocity: 0.1,
					   options: .curveEaseInOut,
					   animations: { () -> Void in
						self.table.frame = CGRect(x: self.pointToParent.x,
												  y: y,
												  width: self.frame.width,
												  height: self.tableheightX)
						self.shadow.frame = self.table.frame
//                        self.shadow.dropShadow()

		},
					   completion: { (didFinish) -> Void in
					  //  self.shadow.layer.shadowPath = UIBezierPath(rect: self.table.bounds).cgPath
						self.layoutIfNeeded()

		})
	}

	//MARK: Actions Methods
	public func didSelect(completion: @escaping (_ selectedText: String, _ index: Int , _ id:Int ) -> ()) {
		didSelectCompletion = completion
	}

	public func listWillAppear(completion: @escaping () -> ()) {
		TableWillAppearCompletion = completion
	}

	public func listDidAppear(completion: @escaping () -> ()) {
		TableDidAppearCompletion = completion
	}

	public func listWillDisappear(completion: @escaping () -> ()) {
		TableWillDisappearCompletion = completion
	}

	public func listDidDisappear(completion: @escaping () -> ()) {
		TableDidDisappearCompletion = completion
	}

}

//MARK: UITextFieldDelegate
extension RSDropDown : UITextFieldDelegate {
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		superview?.endEditing(true)
		return false
	}
	public func  textFieldDidBeginEditing(_ textField: UITextField) {
		textField.text = ""
		//self.selectedIndex = nil
		self.dataArray = self.optionArray
		touchAction()
	}
	public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return isSearchEnable
	}

	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if string != "" {
			self.searchText = self.text! + string
		}else{
			let subText = self.text?.dropLast()
			self.searchText = String(subText!)
		}
		if !isSelected {
			showList()
		}
		return true;
	}

}
///MARK: UITableViewDataSource
extension RSDropDown: UITableViewDataSource {

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataArray.count
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: "DropDownCell")

		cell.backgroundColor = indexPath.row != self.selectedIndex ? self.rowBackgroundColor : self.selectedRowColor

		if self.imageArray.count > indexPath.row {
			let imageViewScale: CGFloat = 0.75
			cell.imageView?.image = self.resizeImage(UIImage(named: imageArray[indexPath.row])!, withSize: CGSize(width: self.rowHeight*imageViewScale, height: self.rowHeight*imageViewScale))
			cell.imageView?.contentMode = .center
			cell.imageView?.clipsToBounds = true
			cell.imageView?.layer.cornerRadius = self.imageCellIsRounded ? (self.rowHeight*imageViewScale)/2 : 0
		}
		
		cell.textLabel?.text = "\(dataArray[indexPath.row])"
		cell.accessoryType = (indexPath.row == selectedIndex) && checkMarkEnabled ? .checkmark : .none
		cell.selectionStyle = .none
		cell.tintColor = cell.textLabel?.textColor ?? .label
		cell.textLabel?.font = self.tableCellFont
		cell.textLabel?.textAlignment = self.textAlignment
		cell.textLabel?.numberOfLines = 0
		cell.textLabel?.lineBreakMode = .byWordWrapping
		
		return cell
	}
}

extension RSDropDown {
	func resizeImage( _ image: UIImage, withSize newSize: CGSize) -> UIImage {
		UIGraphicsBeginImageContext(newSize)
		image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage!
	}
}

//MARK: UITableViewDelegate
extension RSDropDown: UITableViewDelegate {
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedIndex = (indexPath as NSIndexPath).row
		let selectedText = self.dataArray[self.selectedIndex!]
		tableView.cellForRow(at: indexPath)?.alpha = 0
		UIView.animate(withDuration: 0.5,
					   animations: { () -> Void in
						tableView.cellForRow(at: indexPath)?.alpha = 1.0
						tableView.cellForRow(at: indexPath)?.backgroundColor = self.selectedRowColor
		} ,
					   completion: { (didFinish) -> Void in
						self.text = "\(selectedText)"

						tableView.reloadData()
		})
		if hideOptionsWhenSelect {
			touchAction()
			self.endEditing(true)
		}
		if let selected = optionArray.firstIndex(where: {$0 == selectedText}) {
			if let id = optionIds?[selected] {
				didSelectCompletion(selectedText, selected , id )
			}else{
				didSelectCompletion(selectedText, selected , 0)
			}

		}

	}
}

//MARK: Arrow
fileprivate enum Position {
	case left
	case down
	case right
	case up
}

fileprivate class Arrow: UIView {
	let shapeLayer = CAShapeLayer()
	var arrowColor: UIColor = .label {
		didSet{
			shapeLayer.fillColor = arrowColor.cgColor
		}
	}
	
	var position: Position = .down {
		didSet{
			switch position {
			case .left:
				self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
				break

			case .down:
				self.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
				break

			case .right:
				self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
				break

			case .up:
				self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
				break
			}
		}
	}

	init(origin: CGPoint, size: CGFloat ) {
		super.init(frame: CGRect(x: origin.x, y: origin.y, width: size, height: size))
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func draw(_ rect: CGRect) {

		// Get size
		let size = self.layer.frame.width

		// Create path
		let bezierPath = UIBezierPath()

		// Draw points
		let qSize = size/4

		bezierPath.move(to: CGPoint(x: 0, y: qSize))
		bezierPath.addLine(to: CGPoint(x: size, y: qSize))
		bezierPath.addLine(to: CGPoint(x: size/2, y: qSize*3))
		bezierPath.addLine(to: CGPoint(x: 0, y: qSize))
		bezierPath.close()

		// Mask to path
		shapeLayer.path = bezierPath.cgPath
		shapeLayer.fillColor = arrowColor.cgColor
	   
		if #available(iOS 12.0, *) {
			self.layer.addSublayer (shapeLayer)
		} else {
			self.layer.mask = shapeLayer
		}
	}
}

fileprivate extension UIView {

	func dropShadow(scale: Bool = true) {
		layer.masksToBounds = false
		layer.shadowColor = UIColor.label.cgColor
		layer.shadowOpacity = 0.3
		layer.shadowOffset = CGSize(width: 1, height: 1)
		layer.shadowRadius = 1
		layer.shadowPath = UIBezierPath(rect: bounds).cgPath
		layer.shouldRasterize = true
		layer.rasterizationScale = scale ? UIScreen.main.scale : 1
	}
	
	func viewBorder(borderColor : UIColor, borderWidth : CGFloat?) {
		self.layer.borderColor = borderColor.cgColor
		if let borderWidth_ = borderWidth {
			self.layer.borderWidth = borderWidth_
		} else {
			self.layer.borderWidth = 1.0
		}
	}
	
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
