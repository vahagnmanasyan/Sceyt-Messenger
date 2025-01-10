//
//  AttachedImagesView.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 10.01.25.
//

import UIKit

protocol AttachedImagesViewDelegate: AnyObject {
    func attachedImagesViewDidDeleteTapped(_ view: AttachedImagesView, image: UIImage?)
}

final class AttachedImagesView: UIView {
    private(set) lazy var imagesStackView: UIStackView = makeImagesStackView()

    weak var delegate: AttachedImagesViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupContent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupContent()
    }

    private func setupContent() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .background
        addSubview(imagesStackView)

        NSLayoutConstraint.activate([
            imagesStackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            imagesStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            imagesStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])

        let divider = DividerView()
        divider.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 1)
        addSubview(divider)
    }

    func addImage(_ image: UIImage) {
        let imageView = makeImageView()
        imageView.image = image
        imagesStackView.addArrangedSubview(imageView)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true

        let tag = imagesStackView.arrangedSubviews.count - 1
        imageView.tag = tag

        let deleteButton = UIButton()
        deleteButton.setImage(.iconClose, for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.tag = tag
        addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.heightAnchor.constraint(equalToConstant: 20.0),
            deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor),
            deleteButton.centerXAnchor.constraint(equalTo: imageView.trailingAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: imageView.topAnchor)
        ])

        deleteButton.addTarget(self, action: #selector(onDeleteButtonTapped(button:)), for: .touchUpInside)
    }
}

// MARK: - Actions

@objc private extension AttachedImagesView {
    func onDeleteButtonTapped(button: UIButton) {
        let tag = button.tag
        button.removeFromSuperview()
        let imageView = imagesStackView.arrangedSubviews
            .first { $0.tag == tag } as? UIImageView
        imageView?.removeFromSuperview()
        delegate?.attachedImagesViewDidDeleteTapped(self, image: imageView?.image)
    }
}

private extension AttachedImagesView {
    func makeImagesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8.0
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
}
