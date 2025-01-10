//
//  ConversationViewModel.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 08.01.25.
//

import UIKit
import Combine
import Foundation

protocol ConversationViewModelType: AnyObject, ObservableObject {
    var inputs: ConversationViewModelInputType { get }
    var outputs: ConversationViewModelOutputType { get }
}

protocol ConversationViewModelInputType {
    func onViewDidLoad()
    func onSendMessage(_ message: String?)
    func onAttachImage(_ image: UIImage)
    func onRemoveAttachedImage(_ image: UIImage)
}

protocol ConversationViewModelOutputType {
    var navigationViewModel: Published<ConversationNameViewModel?>.Publisher { get }
    var messagesCellModels: Published<[MessageCellModel]>.Publisher { get }
    var attachedImagesViewHidden: Published<Bool>.Publisher { get }
}

final class ConversationViewModel: ConversationViewModelType, ConversationViewModelInputType, ConversationViewModelOutputType {
    var inputs: any ConversationViewModelInputType { return self }
    var outputs: any ConversationViewModelOutputType { return self }

    private let dataManager: DataManager
    private let dateFormatter: DateFormatter
    private let currentUserId: String
    private let maxWidth: CGFloat
    private let minWidth: CGFloat
    private let cancellables: Set<AnyCancellable>
    private var attachedImages: [UIImage]

    init() {
        self.attachedImages = []
        self.dateFormatter = DateFormatter()
        self.dateFormatter.locale = Locale(identifier: "en_US")
        self.dateFormatter.dateFormat = "HH:mm"
        self.dataManager = .shared
        self.cancellables = Set<AnyCancellable>()
        self.currentUserId = UserDefaults.standard.string(forKey: "userId")!
        self.maxWidth = UIScreen.main.bounds.width * Constants.maxWidthCoefficient
        self.minWidth = UIScreen.main.bounds.width * Constants.minWidthCoefficient
    }

    // MARK: Inputs

    func onSendMessage(_ message: String?) {
        guard  !(message ?? "").isEmpty || !attachedImages.isEmpty else {
            return
        }

        let id = UUID().uuidString
        let date = Date()
        var imagePath: String?
        if let image = attachedImages.first {
            do {
                imagePath = try saveImage(imageName: id, image: image)
                attachedImages.removeFirst()
            } catch {
                imagePath = nil
            }
        }

        let cellModel = makeMessageCellModel(
            id: id,
            message: message,
            senderName: "",
            senderId: currentUserId,
            date: date,
            photoUrl: imagePath
        )!

        dataManager.saveMessage(
            body: message,
            id: id,
            senderName: "",
            senderId: currentUserId,
            date: date,
            url: imagePath
        )

        _messagesCellModels.insert(cellModel, at: 0)
        
        for image in attachedImages {
            let id = UUID().uuidString
            do {
                let path = try saveImage(imageName: id, image: image)
                let cellModel = makeMessageCellModel(
                    id: id,
                    message: nil,
                    senderName: "",
                    senderId: currentUserId,
                    date: date,
                    photoUrl: path)!
                
                dataManager.saveMessage(
                    body: nil,
                    id: id,
                    senderName: "",
                    senderId: currentUserId,
                    date: date,
                    url: path
                )
                _messagesCellModels.insert(cellModel, at: 0)
            } catch {
                print(error)
            }
        }

        attachedImages.removeAll()
        _attachedImagesViewHidden = true
    }

    func onViewDidLoad() {
        _navigationViewModel = ConversationNameViewModel(
            title: "Tech Hub",
            subtitle: "1.2k members",
            avatarTitle: "TH"
        )

        let messages = dataManager.fetchMessages()
        _messagesCellModels = transform(messages: messages)
            
    }

    func onAttachImage(_ image: UIImage) {
        attachedImages.append(image)
        _attachedImagesViewHidden = false
    }

    func onRemoveAttachedImage(_ image: UIImage) {
        attachedImages.removeAll { $0 == image }
        if attachedImages.count == 0 {
            _attachedImagesViewHidden = true
        }
    }

    // MARK: Outputs

    @Published private var _navigationViewModel: ConversationNameViewModel?
    var navigationViewModel: Published<ConversationNameViewModel?>.Publisher {
        return $_navigationViewModel
    }

    @Published private var _messagesCellModels: [MessageCellModel] = []
    var messagesCellModels: Published<[MessageCellModel]>.Publisher {
        return $_messagesCellModels
    }

    @Published private var _attachedImagesViewHidden: Bool = true
    var attachedImagesViewHidden: Published<Bool>.Publisher {
        return $_attachedImagesViewHidden
    }

    // MARK: Constants

    struct Constants {
        static let maxWidthCoefficient: CGFloat = 0.7
        static let minWidthCoefficient: CGFloat = 0.2
    }
}

// MARK: - Helpers

private extension ConversationViewModel {
    func transform(messages: [CDMessage]) -> [MessageCellModel] {
        return messages.compactMap {
            makeMessageCellModel(
                id: $0.id,
                message: $0.body,
                senderName: $0.senderName,
                senderId: $0.senderId,
                date: $0.date,
                photoUrl: $0.photoUrl
            )
        }
    }
    
    func makeMessageCellModel(
        id: String?,
        message: String?,
        senderName: String?,
        senderId: String?,
        date: Date?,
        photoUrl: String?
    ) -> MessageCellModel? {
        let message = message ?? ""
        guard let id, let senderName, let senderId, let date else {
            return nil
        }

        let isIncomingMessage = currentUserId != senderId
        let nameFont = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        let messageFont = UIFont.systemFont(ofSize: 16.0, weight: .regular)

        let nameHeight = !isIncomingMessage ? senderName.height(withConstrainedWidth: maxWidth, font: nameFont): 0.0
        let textHeight = !message.isEmpty ? message.height(withConstrainedWidth: maxWidth, font: messageFont): 0.0
        let imageHeight = photoUrl != nil ? 260.0 : 0.0
        let contentHeight = nameHeight + textHeight + imageHeight

        let messageWidth = !message.isEmpty ? message.width(withConstrainedHeight: contentHeight, font: messageFont): 0.0
        
        let contentWidth = if photoUrl != nil {
            maxWidth
        } else if messageWidth > maxWidth {
            maxWidth
        } else if messageWidth < minWidth {
            minWidth
        } else {
            messageWidth
        }

        let timeString = dateFormatter.string(from: date)

        return MessageCellModel(
            id: id,
            message: message,
            senderName: senderName,
            sentDate: timeString,
            contentHeight: contentHeight,
            contentWidth: contentWidth,
            photoUrl: photoUrl,
            kind: currentUserId == senderId ? .current: .other,
            displayingAttibutes: .init()
        )
    }
    
    func saveImage(imageName: String, image: UIImage) throws -> String? {
        do {
            let documentsDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            let fileName = "\(imageName).jpg"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            if let data = image.jpegData(compressionQuality:  1),
                !FileManager.default.fileExists(atPath: fileURL.path) {
                try data.write(to: fileURL)
                print("Image saved")
            }

            return fileURL.path
        } catch {
            print("Failed to save image with error: \(error)")
        }
        
        return nil
    }
}
