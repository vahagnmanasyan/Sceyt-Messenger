//
//  ConversationDataSource.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 10.01.25.
//

import UIKit

typealias DataSource = UICollectionViewDiffableDataSource<Int, MessageCellModel>
typealias Snapshot = NSDiffableDataSourceSnapshot<Int, MessageCellModel>

protocol ConversationDataSourceType: AnyObject {
    var onRequestAction: ((ConversationDataSource.RequestAction)-> Void)? { get set }
    func apply(_ snapshot: Snapshot, animatingDifferences: Bool)
}

final class ConversationDataSource: NSObject, ConversationDataSourceType {

    internal enum RequestAction {
        case deleteMessage(MessageCellModel)
        case copy(MessageCellModel)
    }

    private let dataSource: DataSource
    private weak var collectionView: UICollectionView!
    private var sectionIdentifiers: [Int]

    internal var onRequestAction: ((RequestAction)-> Void)?

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.sectionIdentifiers = []
        collectionView.register(MessageCell.self)

        self.dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, cellModel in
            let cell = collectionView.dequeueCell(ofType: MessageCell.self, indexPath: indexPath)
            cell.configure(with: cellModel)
            return cell
        }

        super.init()

        self.collectionView.delegate = self
        self.collectionView.dataSource = dataSource
    }

    func apply(_ snapshot: Snapshot, animatingDifferences: Bool) {
        self.sectionIdentifiers = snapshot.sectionIdentifiers
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}


// MARK: - UICollectionViewDelegate

extension ConversationDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }

        let parameters = UIPreviewParameters()
        let roundedRect = cell.bounds.inset(by: .zero)
        let roundedCorners = UIRectCorner(rawValue: cell.layer.maskedCorners.rawValue)
        let cornerRadii = CGSize(width: cell.layer.cornerRadius, height: cell.layer.cornerRadius)
        parameters.visiblePath = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii)
        parameters.shadowPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii)

        return UITargetedPreview(view: cell, parameters: parameters)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let sectionItem = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        let copyTitle = "Copy"
        let copyIcon = UIImage(systemName: "doc.on.doc")

        let copy = UIAction(title: copyTitle, image: copyIcon) { [weak self] _ in
            self?.onRequestAction?(.copy(sectionItem))
        }

        var menuElements = [UIMenuElement]()

        let deleteTitle = "Delete"
        let deleteImage = UIImage(systemName: "trash")
        let attributes = UIMenu.Attributes.destructive
        let deleteAction = UIAction(title: deleteTitle, image: deleteImage, attributes: attributes) { [weak self] _ in
            self?.onRequestAction?(.deleteMessage(sectionItem))
        }
        let divider = UIMenu(title: "", options: .displayInline, children: [copy])
        menuElements.append(divider)
        menuElements.append(deleteAction)

        let menu = UIMenu(children: menuElements)
        let identifier = indexPath as NSCopying

        return UIContextMenuConfiguration(identifier: identifier, actionProvider: { _ in menu })
    }
}

// MARK: - MessagesCollectionViewLayoutDelegate

extension ConversationDataSource: MessagesCollectionViewLayoutDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: MessagesCollectionViewLayout,
        sizeForMessageHeaderInSection section: Int
    ) -> CGSize {
        if let _ = dataSource.sectionIdentifier(for: section) {
            return CGSize(width: collectionView.bounds.width, height: 40)
        }
        return CGSize.zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: MessagesCollectionViewLayout,
        sizeForMessageAt indexPath: IndexPath
    ) -> CGSize {
        guard let sectionItem = dataSource.itemIdentifier(for: indexPath) else {
            return .zero
        }
        return CGSize(width: sectionItem.contentWidth, height: sectionItem.contentHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: MessagesCollectionViewLayout,
        positionForMessageAt indexPath: IndexPath
    ) -> MessagesCollectionViewLayout.MessagePosition {
        guard let sectionItem = dataSource.itemIdentifier(for: indexPath) else {
            return .leading
        }

        return sectionItem.kind == .current ? .trailing: .leading
    }
}

// MARK: - MessagesDisplayingDelegate

extension ConversationDataSource: MessagesDisplayingDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: MessagesCollectionViewLayout,
        attibutesForDisplayingMessageAt indexPath: IndexPath
    ) -> MessageDisplayingAttibutes? {
        guard let sectionItem = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        return sectionItem.displayingAttibutes
    }
}

protocol MessagesCollectionViewLayoutDelegate: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: MessagesCollectionViewLayout,
        sizeForMessageAt indexPath: IndexPath) -> CGSize

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: MessagesCollectionViewLayout,
        positionForMessageAt indexPath: IndexPath) -> MessagesCollectionViewLayout.MessagePosition
}

protocol MessagesDisplayingDelegate: AnyObject {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: MessagesCollectionViewLayout,
        attibutesForDisplayingMessageAt indexPath: IndexPath) -> MessageDisplayingAttibutes?
}

open class MessagesCollectionViewLayout: UICollectionViewLayout {

    /// Enum representing the message position in collection view.
    enum MessagePosition: Int {
        /// Message position leading.
        case leading
        /// Message position trailing.
        case trailing
    }

    /// Option set representing the messages collection item layout artributes update.
    struct LayoutAttibutesUpdate: OptionSet {
        let rawValue: UInt8

        static let none = LayoutAttibutesUpdate(rawValue: 1 << 0)
        static let alpha = LayoutAttibutesUpdate(rawValue: 1 << 1)
        static let transform = LayoutAttibutesUpdate(rawValue: 1 << 2)

        static let all: LayoutAttibutesUpdate = [.none, .alpha, .transform]
    }

    open override class var layoutAttributesClass: AnyClass {
        return MesssageCollectionViewLayoutAttributes.self
    }

    /// The spacing to use between messages in the.
    ///
    /// The default value of this property is 10.0.
    open var interMessageSpacing: CGFloat = 10

    /// The default size to use for message cells.
    ///
    /// If the delegate does not implement the collectionView(_:layout:sizeForMessageAt:) method,
    /// the layout uses the value in this property to set the size of each cell.
    /// This results in cells that all have the same size.
    /// The default size value is (50.0, 50.0).
    open var messageSize: CGSize = CGSize(width: 50, height: 50)

    /// The default sizes to use for section headers.
    ///
    /// If the delegate does not implement the collectionView(_:layout:sizeForMessageHeaderInSection:) method,
    /// the layout object uses the default header sizes set in this property.
    /// The default size values are (0, 0).
    open var messageHeaderSize: CGSize = CGSize.zero

    /// The margins used to lay out content in a section.
    /// The default edge insets are all set to 0.
    open var messageSectionInset: UIEdgeInsets = UIEdgeInsets.zero

    /// The boundary that section insets are defined in relation to.
    ///
    /// The default value of this property is .fromContentInset.
    /// The minimum value of this property is always the collection view's contentInset.
    /// For example, if the value of this property is UICollectionViewFlowLayout.SectionInsetReference.fromSafeArea,
    /// but the adjusted content inset is greater than the combination of the safe area and section insets,
    /// then the section's content is aligned with the content inset instead.
    open var messageSectionInsetReference: UICollectionViewFlowLayout.SectionInsetReference = .fromContentInset

    private var layoutNeedsUpdate = true
    private var shouldScrollToBottom: Bool = false
    private var collectionViewContentBounds = CGRect.zero
    private var layoutAttributes = [MesssageCollectionViewLayoutAttributes]()
    private var layoutAttributesBySectionAndItem = [[MesssageCollectionViewLayoutAttributes]]()
    private var collectionViewUpdates: [UICollectionViewUpdateItem]?

    open override func prepare() {
        super.prepare()

        guard layoutNeedsUpdate else {
            return
        }

        prepareMessagesLayout()
        layoutNeedsUpdate = false
    }

    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section < layoutAttributesBySectionAndItem.count
            && indexPath.item < layoutAttributesBySectionAndItem[indexPath.section].count {
            return layoutAttributesBySectionAndItem[indexPath.section][indexPath.item]
        }
        return nil
    }

    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()

        // Find any cell that sits within the query rect.
        guard let firstMatchIndex = layoutAttributes.binarySearch(predicate: { attribute in
            if attribute.frame.intersects(rect) {
                return .orderedSame
            }
            if attribute.frame.minY > rect.maxY {
                return .orderedDescending
            }
            return .orderedAscending
        }) else { return attributesArray }

        // Starting from the match, loop up and down through the array until all the attributes
        // have been added within the query rect.
        for attributes in layoutAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }

        for attributes in layoutAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }

        return attributesArray
    }

    open override var collectionViewContentSize: CGSize {
        return collectionViewContentBounds.size
    }

    open override func invalidateLayout() {
        super.invalidateLayout()

        layoutAttributes.removeAll()
        layoutAttributesBySectionAndItem.removeAll()
        layoutNeedsUpdate = true
    }

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }

    // MARK: -  Animation

    public override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }

        let updateType = itemUpdateType(at: itemIndexPath)

        if updateType.contains(.none) {
            layoutAttributes.alpha = 1.0
        } else if updateType.contains(.alpha) {
            layoutAttributes.alpha = 0.0
        }

        if updateType.contains(.transform) {
            let transform = layoutAttributes.transform3D
            let translation = layoutAttributes.size.height + 100
            layoutAttributes.transform3D = CATransform3DTranslate(transform, 0.0, translation, 0.0)
        }


        if itemIndexPath.section == 0 && itemIndexPath.item == 0 {
            self.shouldScrollToBottom = true
        }

        return layoutAttributes
    }

    public override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

        self.collectionViewUpdates = updateItems
    }

    public override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()

        self.collectionViewUpdates = nil

        if shouldScrollToBottom {
            shouldScrollToBottom = false
            let indexPath = IndexPath(item: 0, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - Helpers

private extension MessagesCollectionViewLayout {

    func prepareMessagesLayout() {
        guard let collectionView = collectionView else {
            return
        }

        var lastLayoutAttibutesFrame: CGRect = .zero
        collectionViewContentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)

        let messageLayoutDelegate = collectionView.delegate as? MessagesCollectionViewLayoutDelegate
        let messageDisplayingDelegate = collectionView.delegate as? MessagesDisplayingDelegate

        let numberOfSections = collectionView.numberOfSections

        for section in 0..<numberOfSections {
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            var sectionLayoutAttibutes = [MesssageCollectionViewLayoutAttributes]()

            lastLayoutAttibutesFrame.origin.y += messageSectionInset.top
            // Cell layout attibutes calculation.

            for itemIndex in 0..<numberOfItems {
                let indexPath = IndexPath(item: itemIndex, section: section)
                let cellLayoutAttributes = MesssageCollectionViewLayoutAttributes(forCellWith: indexPath)

                let messagePosition = messageLayoutDelegate?.collectionView(collectionView, layout: self, positionForMessageAt: indexPath) ?? .leading
                let messageSize = messageLayoutDelegate?.collectionView(collectionView, layout: self, sizeForMessageAt: indexPath) ?? messageSize
                let messageDisplayingAttributes = messageDisplayingDelegate?.collectionView(collectionView, layout: self, attibutesForDisplayingMessageAt: indexPath)

                cellLayoutAttributes.messageDisplayingAttributes = messageDisplayingAttributes

                var cellLayoutPosition = CGPoint.zero

                let additionalSectionInset = {
                    var additionalSectionInset = UIEdgeInsets.zero
                    switch messageSectionInsetReference {
                    case .fromSafeArea:
                        additionalSectionInset.left = collectionView.safeAreaInsets.left + collectionView.contentInset.left + messageSectionInset.left
                        additionalSectionInset.right = collectionView.safeAreaInsets.right + collectionView.contentInset.right + messageSectionInset.right
                    case .fromContentInset:
                        additionalSectionInset.left = collectionView.contentInset.left + messageSectionInset.left
                        additionalSectionInset.right = collectionView.contentInset.right + messageSectionInset.right
                    case .fromLayoutMargins:
                        additionalSectionInset.left = collectionView.layoutMargins.left + messageSectionInset.left
                        additionalSectionInset.right = collectionView.layoutMargins.right + messageSectionInset.right
                    @unknown default:
                        additionalSectionInset = messageSectionInset
                    }
                    return additionalSectionInset
                }()

                switch messagePosition {
                case .leading:
                    cellLayoutPosition.x = additionalSectionInset.left
                case .trailing:
                    cellLayoutPosition.x = collectionViewContentBounds.width - (messageSize.width + additionalSectionInset.right)
                }

                cellLayoutPosition.y = lastLayoutAttibutesFrame.maxY + interMessageSpacing
                cellLayoutAttributes.frame = CGRect(origin: cellLayoutPosition, size: messageSize)
                layoutAttributes.append(cellLayoutAttributes)
                lastLayoutAttibutesFrame = cellLayoutAttributes.frame
                collectionViewContentBounds = collectionViewContentBounds.union(lastLayoutAttibutesFrame)
                sectionLayoutAttibutes.append(cellLayoutAttributes)
            }

            layoutAttributesBySectionAndItem.append(sectionLayoutAttibutes)
        }
    }

    func itemUpdateType(at itemIndexPath: IndexPath)-> LayoutAttibutesUpdate {
        let collectionViewUpdates = collectionViewUpdates ?? []

        // Check single row animation.
        if collectionViewUpdates.count == 2 {
            let firstUpdate = collectionViewUpdates[0]
            let lastUpdate = collectionViewUpdates[1]
            if firstUpdate.updateAction == .delete && lastUpdate.updateAction == .insert {
                if firstUpdate.indexPathBeforeUpdate == lastUpdate.indexPathAfterUpdate {
                    return .none
                }
            }
        }

        for collectionViewUpdate in collectionViewUpdates {
            if collectionViewUpdate.updateAction == .insert,
               collectionViewUpdate.indexPathAfterUpdate == itemIndexPath {
                return [.alpha, .transform]
            }
        }

        return .alpha
    }
}


private extension Array {

    func binarySearch(predicate: (Element) -> ComparisonResult) -> Index? {
        var lowerBound = startIndex
        var upperBound = endIndex

        while lowerBound < upperBound {
            let midIndex = lowerBound + (upperBound - lowerBound) / 2
            if predicate(self[midIndex]) == .orderedSame {
                return midIndex
            } else if predicate(self[midIndex]) == .orderedAscending {
                lowerBound = midIndex + 1
            } else {
                upperBound = midIndex
            }
        }
        return nil
    }
}

struct ChatAppearance {

    struct Message {

        static var interMessageSpacing: CGFloat = 4.0
        static var incomingMessageLeading: CGFloat = 16.0
        static var incomingMessageTrailing: CGFloat = 112.0
        static var incomingEmojiMessageTrailing: CGFloat = 40.0
        static var outgoingMessageLeading: CGFloat = 132.0
        static var outgoingMessageTrailing: CGFloat = 16.0
        static var outgoingEmojiMessageLeading: CGFloat = 60.0
        
        static var incomingMessageTextColor: UIColor = UIColor.red
        static var outgoingMessageTextColor: UIColor = UIColor.green

        static var font: UIFont = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        static var insets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        
        static var cornerRadius: CGFloat = 20.0

        static var incomingMessageBackground: UIColor = UIColor.message
        static var outgoingMessageBackground: UIColor = UIColor.messageCurrent

        static var dataDetectorTypes: UIDataDetectorTypes = [.phoneNumber, .link]
        
        static var incomingLinkTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue,
            .font: ChatAppearance.Message.font,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.systemBlue.withAlphaComponent(0.6)
        ]
        
        static var outgoingLinkTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: ChatAppearance.Message.font,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white.withAlphaComponent(0.6)
        ]
    }

    struct Date {
        static var font = UIFont.systemFont(ofSize: 13.0, weight: .black)
        static var textColor = UIColor.gray
        static let height: CGFloat = 40.0
    }
    
    struct Layout {
        static let transform3D = CATransform3DMakeScale(1, -1, 1)
    }
}

class MesssageCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var messageDisplayingAttributes: MessageDisplayingAttibutes?

    override init() {
        super.init()

        self.transform3D = ChatAppearance.Layout.transform3D
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! MesssageCollectionViewLayoutAttributes
        copy.messageDisplayingAttributes = messageDisplayingAttributes
        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let layoutAttributes = object as? MesssageCollectionViewLayoutAttributes,
              let displayingAttributes = layoutAttributes.messageDisplayingAttributes,
              let messageDisplayingAttributes = messageDisplayingAttributes,
              super.isEqual(object) else {
            return false
        }

        return displayingAttributes.messageBackgroundColor == messageDisplayingAttributes.messageBackgroundColor &&
        displayingAttributes.messageSize == messageDisplayingAttributes.messageSize &&
        displayingAttributes.messageTextColor == messageDisplayingAttributes.messageTextColor &&
        displayingAttributes.messageFont == messageDisplayingAttributes.messageFont &&
        displayingAttributes.messageTextAlignment == messageDisplayingAttributes.messageTextAlignment &&
        displayingAttributes.messageDataDetectorTypes == messageDisplayingAttributes.messageDataDetectorTypes &&
        displayingAttributes.dateLabelSize == messageDisplayingAttributes.dateLabelSize &&
        displayingAttributes.messageDateTextColor == messageDisplayingAttributes.messageDateTextColor &&
        displayingAttributes.messageDateLabelFont == messageDisplayingAttributes.messageDateLabelFont &&
        displayingAttributes.messageDateLabelPadding == messageDisplayingAttributes.messageDateLabelPadding
    }
}

final class MessageDisplayingAttibutes {
    var messageSize: CGSize = .zero
    let messageFont: UIFont = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    let messageTextColor: UIColor = UIColor.black
    let messageBackgroundColor: UIColor = .clear
    let messageTextAlignment: NSTextAlignment = .left
    let messageDataDetectorTypes: UIDataDetectorTypes = []

    let linkTextAttributes: [NSAttributedString.Key: Any] = [:]
    let dateLabelSize: CGSize = .zero

    let messageDateTextColor: UIColor = .tertiaryLabel
    let messageDateLabelFont: UIFont = .systemFont(ofSize: 13)
    let messageDateLabelPadding: UIEdgeInsets = .zero
}
