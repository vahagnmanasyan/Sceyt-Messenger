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
    private lazy var avatarStackView: UIStackView = makeAvatarStackView()
    private lazy var dateLabel: UILabel = makeDateLabel()
    private lazy var attachedImageView: UIImageView = makeAttachedImageView()
    private lazy var mediaStackView: UIStackView = makeMediaStackView()

    private var mediaHeightAnchor: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupContent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupContent()
    }

    func setupContent() {
        contentView.addSubview(avatarStackView)
        contentView.addSubview(messageContainerView)
        avatarStackView.addArrangedSubview(avatarImageView)
        messageContainerView.addSubview(messageStackView)
        messageStackView.addArrangedSubview(nameLabel)
        messageStackView.addArrangedSubview(messageTextView)
        messageContainerView.addSubview(mediaStackView)
        
        mediaStackView.addArrangedSubview(attachedImageView)
        
        NSLayoutConstraint.activate([
            avatarStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            avatarStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            avatarStackView.trailingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: -10.0),
            avatarStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32.0),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),

            messageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            messageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            messageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            messageStackView.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 8.0),
            messageStackView.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 12.0),
            messageStackView.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -12.0),
            messageStackView.bottomAnchor.constraint(equalTo: mediaStackView.topAnchor, constant: -8),
            
            mediaStackView.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 2.0),
            mediaStackView.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -2.0),
            mediaStackView.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -2),
        ])

        self.mediaHeightAnchor = mediaStackView.heightAnchor.constraint(equalToConstant: 0.0)
        self.mediaHeightAnchor?.isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = ""
        messageTextView.text = ""
    }

    func configure(with cellModel: MessageCellModel) {
        nameLabel.text = cellModel.senderName
        messageTextView.text = cellModel.message
        
        if let photoUrl = cellModel.photoUrl {
            Task {
                await attachedImageView.setImage(from: photoUrl)
            }
            
            mediaHeightAnchor?.constant = 260.0
        } else if let image = cellModel.image {
            attachedImageView.image = image
            mediaHeightAnchor?.constant = 260.0
        } else {
            mediaHeightAnchor?.constant = 0.0
        }

        
        switch cellModel.kind {
        case .current:
            nameLabel.isHidden = true
            avatarImageView.isHidden = true
        case .other:
            nameLabel.isHidden = false
            avatarImageView.isHidden = false
        }
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
        imageView.image = .avatarPlaceholder
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    func makeDateLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor(0x7C7E8E)
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .black)
        return label
    }

    func makeAttachedImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = .placeholder
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }

    func makeMediaStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    func makeAvatarStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.alignment = .top
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}
