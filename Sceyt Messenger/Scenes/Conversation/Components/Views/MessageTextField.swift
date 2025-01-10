//
//  MessageTextField.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 07.01.25.
//

import UIKit

final class MessageTextField: UIView {

    private lazy var stackView: UIStackView = makeStackView()
    private(set) lazy var attachButton: UIButton = makeAttachButton()
    private(set) lazy var textField: UITextField = makeTextField()
    private(set) lazy var sendButton: UIButton = makeSendButton()

    // MARK: Init

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
        addSubview(stackView)
        stackView.addArrangedSubview(attachButton)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(sendButton)

        let divider = DividerView()
        divider.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 1)
        addSubview(divider)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 36.0),
            attachButton.heightAnchor.constraint(equalToConstant: 52.0),
            attachButton.widthAnchor.constraint(equalTo: attachButton.heightAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 52.0),
            sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor)
        ])
    }
}

private extension MessageTextField {
    func makeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    func makeAttachButton() -> UIButton {
        let button = UIButton()
        button.setImage(.iconAttach, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func makeSendButton() -> UIButton {
        let button = UIButton()
        button.setImage(.iconSend, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func makeTextField() -> UITextField {
        let textField = UITextField()
        textField.layer.cornerRadius = 18.0
        textField.backgroundColor = .textFieldBackground
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor:  UIColor(0xA0A1B0),
            .font: UIFont.systemFont(ofSize: 16.0, weight: .regular)
        ]
        textField.leftViewMode = .always
        let view = UIView()
        view.frame.size = CGSize(width: 12.0, height: 12.0)
        textField.leftView = view
        textField.rightView = view
        textField.rightViewMode = .always
        textField.leftViewMode = .always
        let placeholderText = NSLocalizedString("converstaion.text.field.placeholder", comment: "")
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        return textField
    }
}
