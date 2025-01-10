//
//  ConversationView.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 07.01.25.
//

import UIKit

final class ConversationView: UIView {
    private(set) lazy var collectionView: UICollectionView = makeCollectionView()
    private(set) lazy var messageTextField: MessageTextField = makeMessageTextField()
    private(set) lazy var attachedImagesView: AttachedImagesView = AttachedImagesView()
    private(set) var messageTextFieldBottomAnchor: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupContent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupContent()
    }

    func setupContent() {
        backgroundColor = .background
        addSubview(collectionView)
        addSubview(messageTextField)
        addSubview(attachedImagesView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 52.0),
            attachedImagesView.leadingAnchor.constraint(equalTo: leadingAnchor),
            attachedImagesView.trailingAnchor.constraint(equalTo: trailingAnchor),
            attachedImagesView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor),
            attachedImagesView.heightAnchor.constraint(equalToConstant: 52.0)
        ])

        messageTextFieldBottomAnchor = messageTextField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        messageTextFieldBottomAnchor?.isActive = true
    }
}

private extension ConversationView {
    func makeCollectionView() -> UICollectionView {
        let layout = MessagesCollectionViewLayout()
        let collectionView = MesssagesCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .background
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }

    func makeMessageTextField() -> MessageTextField {
        let textField = MessageTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
}
