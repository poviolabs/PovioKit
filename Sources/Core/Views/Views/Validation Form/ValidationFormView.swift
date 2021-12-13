//
//  ValidationFormView.swift
//  PovioKit
//
//  Created by Toni Kocjan on 10/09/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit

public protocol ValidationFormViewDelegate: AnyObject {
  func validationFormDidScroll<F: ValidationForm>(_ validationFormView: ValidationFormView<F>)
  func validationFormDidTranslateForKeyboardAppereance<F: ValidationForm>(
    _ validationFormView: ValidationFormView<F>,
    offset: CGFloat,
    withDuration: TimeInterval)
}

public class ValidationFormView<F: ValidationForm>: UIView, UICollectionViewDelegateFlowLayout {
  private let validationForm: F
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
  private let layout = UICollectionViewFlowLayout()
  public weak var delegate: ValidationFormViewDelegate?
  public var automaticallyHandleKeyboardAppereance: Bool = true
  private lazy var parser: KeyboardNotificationParser = .init()
  
  public init(validationForm: F) {
    self.validationForm = validationForm
    super.init(frame: .zero)
    setupViews()
    _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { self.processKeyboardNotification($0, shown: true) }
    _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { self.processKeyboardNotification($0, shown: false) }
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    layout.estimatedItemSize = .init(
      width: collectionView.frame.width - collectionView.contentInset.horizontal,
      height: 1)
  }
  
  // MARK: - UICollectionViewDelegateFlowLayout
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    validationForm[indexPath]?.didSelectCallback?()
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    delegate?.validationFormDidScroll(self)
  }
  
  // MARK: - API
  public override var backgroundColor: UIColor? {
    get { collectionView.backgroundColor }
    set { collectionView.backgroundColor = newValue }
  }
}

// MARK: - API
public extension ValidationFormView {
  func register<T: ValidationFormCell>(_: T.Type) {
    collectionView.register(T.self, forCellWithReuseIdentifier: T.identifier)
  }
  
  @discardableResult
  func validate() -> Bool {
    validationForm.validate(in: collectionView)
  }
  
  func validateRow(at index: Int) -> Bool {
    validationForm.validateRow(at: index, in: collectionView)
  }
  
  func validateRow(key: String) -> Bool {
    validationForm.validateRow(key: key, in: collectionView)
  }
  
  func updateRow(key: String, value: Any?) {
    validationForm.updateRow(key: key, value: value, in: collectionView)
  }
  
  func updateValidationStatus<R: ValidatableValidationFormRowType>(
    _ type: R.Type,
    key: String,
    validationStatus: R.ValidationStatus
  ) {
    validationForm.updateValidationStatus(
      type,
      key: key,
      validationStatus: validationStatus,
      in: collectionView)
  }
  
  func generate<D: Decodable>(_ model: D.Type, decoder: JSONDecoder) throws -> D {
    try validationForm.generate(model, decoder: decoder)
  }
  
  func populateForm<T>(_ model: T) {
    validationForm.populateForm(model, in: collectionView)
  }
  
  func setContentOffset(_ point: CGPoint) {
    collectionView.setContentOffset(point, animated: true)
  }
  
  func cell(for key: String) -> UICollectionViewCell? {
    validationForm
      .rowIndex(key: key)
      .flatMap { collectionView.cellForItem(at: .init(row: $0, section: 0)) }
  }
  
  var contentInset: UIEdgeInsets {
    get { collectionView.contentInset }
    set { collectionView.contentInset = newValue }
  }
  
  var alwaysBounceVertical: Bool {
    get { collectionView.alwaysBounceVertical }
    set { collectionView.alwaysBounceVertical = newValue }
  }
  
  var keyboardDismissMode: UIScrollView.KeyboardDismissMode {
    get { collectionView.keyboardDismissMode }
    set { collectionView.keyboardDismissMode = newValue }
  }
  
  var isScrollEnabled: Bool {
    get { collectionView.isScrollEnabled }
    set { collectionView.isScrollEnabled = newValue }
  }
  
  var form: F { validationForm }
  var contentOffset: CGPoint { collectionView.contentOffset }
}

// MARK: - Private
extension ValidationFormView {
  func setupViews() {
    setupCollectionView()
  }
  
  func setupCollectionView() {
    addSubview(collectionView)
    collectionView.delegate = self
    collectionView.dataSource = validationForm
    collectionView.collectionViewLayout = layout
    keyboardDismissMode = .onDrag
    alwaysBounceVertical = true
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    NSLayoutConstraint.activate([
      collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: self.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
    collectionView.translatesAutoresizingMaskIntoConstraints = false
  }
}

// MARK: - Keyboard notifications
extension ValidationFormView {
  func processKeyboardNotification(_ notification: Notification, shown: Bool) {
    do {
      let (animationDuration, keyboardSize, _) = try parser.parse(from: notification)
      shown ?
        keyboardWillShow(animationDuration: animationDuration, keyboardSize: keyboardSize) :
        keyboardWillHide(animationDuration: animationDuration, keyboardSize: keyboardSize)
    } catch {
      Logger.error("Error parsing keyboard notification: \(error.localizedDescription)")
    }
  }
  
  func keyboardWillShow(animationDuration: CGFloat, keyboardSize: CGSize) {
    func isCellEditing(_ cell: UICollectionViewCell) -> Bool {
      func isViewEditing(_ view: UIView) -> Bool {
        switch view {
        case let textView as UITextView where textView.isFirstResponder:
          return true
        case let textField as UITextField where textField.isFirstResponder:
          return true
        case let view:
          return view.subviews.contains(where: isViewEditing)
        }
      }
      return cell.subviews.contains(where: isViewEditing)
    }
    
    guard automaticallyHandleKeyboardAppereance else { return }
    
    for cell in collectionView.visibleCells {
      guard isCellEditing(cell) else { continue }
      let frame = convert(cell.frame, to: window)
      let keyboardMaxY = UIScreen.main.bounds.height - keyboardSize.height
      let overlap = frame.maxY - keyboardMaxY - contentOffset.y

      guard overlap > 0 else { return }
      
      let duration = TimeInterval(animationDuration)
      let offset = -overlap - 45
      UIView.animate(withDuration: duration) {
        self.transform = CGAffineTransform.identity
          .translatedBy(x: 0, y: offset)
      }
      delegate?.validationFormDidTranslateForKeyboardAppereance(self, offset: offset, withDuration: duration)
      
      break
    }
  }
  
  func keyboardWillHide(animationDuration: CGFloat, keyboardSize: CGSize) {
    guard automaticallyHandleKeyboardAppereance else { return }
    UIView.animate(withDuration: TimeInterval(animationDuration)) {
      self.transform = .identity
    }
    delegate?.validationFormDidTranslateForKeyboardAppereance(self, offset: 0, withDuration: TimeInterval(animationDuration))
  }
}

struct KeyboardNotificationParser {
  typealias KeyboardNotification = (animationDuration: CGFloat, keyboardSize: CGSize, animationCurve: UIView.AnimationOptions)
  
  enum Error: Swift.Error {
    case parsingNotificationFailed
    
    var localizedDescription: String {
      switch self {
      case .parsingNotificationFailed:
        return "Notification contains invalid data!"
      }
    }
  }
  
  func parse(from notification: Notification) throws -> KeyboardNotification {
    guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else { throw Error.parsingNotificationFailed }
    guard let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat) else { throw Error.parsingNotificationFailed }
    let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
    return (
      animationDuration,
      keyboardSize,
      animationCurve.map { UIView.AnimationOptions(rawValue: $0 << 16) } ?? .init()
    )
  }
}
