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
    private let currentUserId: String
    private let cancellables: Set<AnyCancellable>

    init() {
        self.dataManager = .shared
        self.cancellables = Set<AnyCancellable>()
        self.currentUserId = UserDefaults.standard.string(forKey: "userId")!
    }

    // MARK: Inputs

    func onSendMessage(_ message: String) {
        let cellModel = MessageCellModel(
            id: UUID().uuidString,
            message: message,
            senderName: "Sceyt",
            sentDate: "13:34",
            contentHeight: 112,
            contentWidth: 123,
            kind: .current
        )
        dataManager.saveMessage(body: message, id: UUID().uuidString, senderName: "Sceyt", senderId: currentUserId)
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
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "HH:mm"
        let maxWidth = UIScreen.main.bounds.width * Constants.maxWidthCoefficient
        let minWidth = UIScreen.main.bounds.width * Constants.minWidthCoefficient

        return messages.compactMap {
            if let id = $0.id, let message = $0.body, let name = $0.senderName, let date = $0.date {
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

                let timeString = formatter.string(from: date)

                return MessageCellModel(
                    id: id,
                    message: message,
                    senderName: name,
                    sentDate: timeString,
                    contentHeight: contentHeight,
                    contentWidth: contentWidth,
                    kind: currentUserId == $0.senderId ? .current: .other
                )
            }

            return nil
        }
    }
}
