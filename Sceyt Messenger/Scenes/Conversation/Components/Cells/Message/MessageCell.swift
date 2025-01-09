//
//  MessageCell.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 07.01.25.
//

import UIKit

final class MessageCell: UICollectionViewCell {
    private lazy var messageContainerView: UIView = makeMessageContainerView()
    private lazy var messageStackView: UIStackView = makeMessageStackView()
    private lazy var nameLabel: UILabel = makeNameLabel()
    private lazy var messageTextView: UITextView = makeMessageTextView()
    private lazy var avatarImageView: UIImageView = makeAvatarImageView()
    private lazy var dateLabel: UILabel = makeDateLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupContent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupContent()
    }

    func setupContent() {
        contentView.addSubview(messageContainerView)
        messageContainerView.addSubview(messageStackView)
        messageStackView.addArrangedSubview(nameLabel)
        messageStackView.addArrangedSubview(messageTextView)

        
        NSLayoutConstraint.activate([
            messageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            messageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            messageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            messageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            messageStackView.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 8.0),
            messageStackView.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 12.0),
            messageStackView.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -12.0),
            messageStackView.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -8)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = ""
        messageTextView.text = ""
    }

    func configure(with cellModel: MessageCellModel) {
        nameLabel.text = cellModel.senderName
        messageTextView.text = cellModel.message
        
        switch cellModel.kind {
        case .current:
            nameLabel.isHidden = true
        case .other:
            nameLabel.isHidden = false
        }
//        messageContainerView.heightAnchor.constraint(equalToConstant: cellModel.contentHeight)
//        messageContainerView.widthAnchor.constraint(equalToConstant: cellModel.contentWidth)
    }
}

private extension MessageCell {
    func makeMessageContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .message
        view.layer.cornerRadius = 16.0
        view.clipsToBounds = true
        return view
    }

    func makeMessageStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 2.0
        return stackView
    }

    func makeNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        label.textColor = .primary
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    func makeMessageTextView() -> UITextView {
        let textView = UITextView()
        textView.textContainerInset = .zero
        textView.contentInset = .zero
        textView.backgroundColor = .message
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        textView.textColor = .textPrimary
        textView.textAlignment = .left
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }

    func makeAvatarImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16.0
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = true
        return imageView
    }

    func makeDateLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor(0x7C7E8E)
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .black)
        return label
    }
}
