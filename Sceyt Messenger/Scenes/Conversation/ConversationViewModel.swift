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
    func onSendMessage(_ message: String)
}

protocol ConversationViewModelOutputType {
    var navigationViewModel: Published<ConversationNameViewModel?>.Publisher { get }
    var messagesCellModels: Published<[MessageCellModel]>.Publisher { get }
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

    init() {
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

    func onSendMessage(_ message: String) {
        let id = UUID().uuidString
        let date = Date()
        let cellModel = makeMessageCellModel(
            id: id,
            message: message,
            senderName: "",
            senderId: currentUserId,
            date: date
        )!

        dataManager.saveMessage(
            body: message,
            id: id,
            senderName: "",
            senderId: currentUserId,
            date: date
        )

        _messagesCellModels.append(cellModel)
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

    // MARK: Outputs

    @Published private var _navigationViewModel: ConversationNameViewModel?
    var navigationViewModel: Published<ConversationNameViewModel?>.Publisher {
        return $_navigationViewModel
    }

    @Published private var _messagesCellModels: [MessageCellModel] = []
    var messagesCellModels: Published<[MessageCellModel]>.Publisher {
        return $_messagesCellModels
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
                date: $0.date
            )
        }
    }
    
    func makeMessageCellModel(
        id: String?,
        message: String?,
        senderName: String?,
        senderId: String?,
        date: Date?
    ) -> MessageCellModel? {
        guard let id, let message, let senderName, let senderId, let date else {
            return nil
        }

        let font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        let contentHeight = message.height(withConstrainedWidth: maxWidth, font: font) + 18.0
        let messageWidth = message.width(withConstrainedHeight: contentHeight, font: font) + 16.0
        
        let contentWidth = if messageWidth < minWidth {
            minWidth
        } else if messageWidth > maxWidth {
            maxWidth
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
            contentWidth: maxWidth,
            kind: currentUserId == senderId ? .current: .other
        )
    }
}
