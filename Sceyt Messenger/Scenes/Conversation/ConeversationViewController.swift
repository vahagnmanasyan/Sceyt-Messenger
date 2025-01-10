//
//  ConversationViewController.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 06.01.25.
//

import UIKit
import Combine
import CoreData

final class ConversationViewController: UIViewController {
    private lazy var contentView: ConversationView = ConversationView()
    private let viewModel: any ConversationViewModelType = ConversationViewModel()
    private var cancellables = Set<AnyCancellable>()

    private var dataSource: DataSource!

    override func loadView() {
        super.loadView()

        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.inputs.onViewDidLoad()
        configureContentView()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        contentView.collectionView.scrollToBottom(animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    func bindViewModel() {
        viewModel.outputs.navigationViewModel
            .receive(on: DispatchQueue.main)
            .compactMap({ $0 })
            .sink { [weak self] viewModel in
                let view = ConversationNameView()
                view.configure(with: viewModel)
                self?.navigationItem.titleView = view
            }
            .store(in: &cancellables)

        viewModel.outputs.messagesCellModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cellModels in
                self?.applySnapshot(with: cellModels)
            }
            .store(in: &cancellables)
    }

    private func configureContentView() {
        dataSource = makeDataSource(contentView.collectionView)
        contentView.collectionView.delegate = self
        contentView.collectionView.register(MessageCell.self, forCellWithReuseIdentifier: "MessageCell")
        contentView.messageTextField.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentViewTapped))
        contentView.addGestureRecognizer(tapGesture)
    }

    private func applySnapshot(with cellModels: [MessageCellModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(cellModels, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
        contentView.collectionView.scrollToBottom(animated: true)
    }

    @objc func keyboardWillShow(notification: Notification) {
        let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        if let keyboardHeight, let animationDuration {
            contentView.messageTextFieldBottomAnchor?.constant = -keyboardHeight
            UIView.animate(withDuration: animationDuration) { [unowned self] in
                contentView.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        DispatchQueue.main.async { [unowned self] in
            contentView.messageTextFieldBottomAnchor?.constant = 0
            UIView.animate(withDuration: 0.25) { [unowned self] in
                contentView.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ConversationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let items = dataSource.snapshot().itemIdentifiers(inSection: indexPath.section)
        let item = items[indexPath.item]
        return CGSize(width: item.contentWidth, height: item.contentHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
}

// MARK: - Actions

@objc private extension ConversationViewController {
    func sendButtonTapped() {
        guard let text = contentView.messageTextField.textField.text, text.count >= 1 else {
            return
        }

        viewModel.inputs.onSendMessage(text)
        contentView.messageTextField.textField.text = nil
    }

    func attachButtonTapped() {

    }

    func contentViewTapped() {
        view.endEditing(true)
    }
}

// MARK: - DataSource

typealias DataSource = UICollectionViewDiffableDataSource<Int, MessageCellModel>
typealias Snapshot = NSDiffableDataSourceSnapshot<Int, MessageCellModel>

private extension ConversationViewController {
    func makeDataSource(_ collectionView: UICollectionView) -> DataSource {
        return DataSource(collectionView: collectionView) { collectionView, indexPath, cellModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.configure(with: cellModel)
            return cell
        }
    }
}

class DataManager {
    static let shared = DataManager()

    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func saveMessage(body: String, id: String, senderName: String, senderId: String, date: Date) {
        do {
            let message = CDMessage(context: context)
            message.body = body
            message.id = id
            message.senderName = senderName
            message.senderId = senderId
            message.date = date
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func fetchMessages() -> [CDMessage] {
        let request: NSFetchRequest<CDMessage> = CDMessage.fetchRequest()
        var fetchedMessages: [CDMessage] = []

        do {
            fetchedMessages = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error fetching messages \(error)")
        }

        return fetchedMessages
    }

    func deleteMessage(message: CDMessage) {
        let context = persistentContainer.viewContext
        context.delete(message)
        save()
    }
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = 12.0
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}
