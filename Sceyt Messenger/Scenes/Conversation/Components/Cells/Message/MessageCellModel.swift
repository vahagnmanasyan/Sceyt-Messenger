//
//  MessageCellModel.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 10.01.25.
//

import Foundation

struct MessageCellModel {
    let id: String
    let message: String
    let senderName: String
    let sentDate: String
    let contentHeight: CGFloat
    let contentWidth: CGFloat
    let kind: Kind

    enum Kind {
        case other
        case current
    }
}

// MARK: - Hashable

extension MessageCellModel: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("message.cell.model.\(id)")
    }
}
