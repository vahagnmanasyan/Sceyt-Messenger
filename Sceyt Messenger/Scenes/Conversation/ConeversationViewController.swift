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

    private var dataSource: ConversationDataSource!

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

        viewModel.outputs.attachedImagesViewHidden
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHidden in
                self?.contentView.attachedImagesView.isHidden = isHidden
                if isHidden {
                    self?.contentView.attachedImagesView.imagesStackView.arrangedSubviews.forEach{
                        $0.removeFromSuperview()
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func configureContentView() {
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsOnTap = false
        dataSource = ConversationDataSource(collectionView: contentView.collectionView)
        contentView.messageTextField.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        contentView.messageTextField.attachButton.addTarget(self, action: #selector(attachButtonTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentViewTapped))
        contentView.addGestureRecognizer(tapGesture)
    }

    private func applySnapshot(with cellModels: [MessageCellModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(cellModels, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
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

// MARK: - Actions

@objc private extension ConversationViewController {
    func sendButtonTapped() {
        let text = contentView.messageTextField.textField.text
        viewModel.inputs.onSendMessage(text)
        contentView.messageTextField.textField.text = nil
    }

    func attachButtonTapped() {
        let imagePickerController = UIImagePickerController()
            imagePickerController.allowsEditing = false
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
    }

    func contentViewTapped() {
        view.endEditing(true)
    }
}

extension ConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        viewModel.inputs.onAttachImage(tempImage)
        contentView.attachedImagesView.addImage(tempImage)
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ConversationViewController: AttachedImagesViewDelegate {
    func attachedImagesViewDidDeleteTapped(_ view: AttachedImagesView, image: UIImage?) {
        if let image {
            viewModel.inputs.onRemoveAttachedImage(image)
        }
    }
}
