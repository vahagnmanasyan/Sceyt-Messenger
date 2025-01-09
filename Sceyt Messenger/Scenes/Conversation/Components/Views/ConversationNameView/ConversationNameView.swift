//
//  ConversationNameView.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 08.01.25.
//

import UIKit

final class ConversationNameView: UIView {
    private lazy var horizontalStackView: UIStackView = makeHorizontalStackView()
    private lazy var verticalStackView: UIStackView = makeVerticalStackView()
    private lazy var avatarBackgroundView: UIView = makeAvatarBackgroundView()
    private lazy var avatarLabel: UILabel = makeAvatarLabel()
    private lazy var titleLabel: UILabel = makeTitleLabel()
    private lazy var subtitleLabel: UILabel = makeSubtitleLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupContent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupContent()
    }

    func setupContent() {
        addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(avatarBackgroundView)
        avatarBackgroundView.addSubview(avatarLabel)
        horizontalStackView.addArrangedSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subtitleLabel)

        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.addArrangedSubview(spacerView)
        let spacerWidthConstraint = spacerView.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        spacerWidthConstraint.priority = .defaultLow
        spacerWidthConstraint.isActive = true

        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: topAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            avatarLabel.centerXAnchor.constraint(equalTo: avatarBackgroundView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarBackgroundView.centerYAnchor),
            avatarBackgroundView.heightAnchor.constraint(equalToConstant: 36.0),
            avatarBackgroundView.widthAnchor.constraint(equalTo: avatarBackgroundView.heightAnchor),
        ])
    }

    func configure(with viewModel: ConversationNameViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        avatarLabel.text = viewModel.avatarTitle
    }
}

private extension ConversationNameView {
    func makeHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 12.0
        return stackView
    }

    func makeVerticalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 0.0
        return stackView
    }
    func makeAvatarBackgroundView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 18.0
        view.backgroundColor = .primary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func makeAvatarLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16.0, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16.0, weight: .semibold)
        label.textColor = .textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func makeSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13.0, weight: .regular)
        label.textColor = .textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
