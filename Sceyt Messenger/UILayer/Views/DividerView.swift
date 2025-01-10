//
//  DividerView.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 10.01.25.
//

import UIKit

final class DividerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .textFieldBackground
        autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
    }
}
