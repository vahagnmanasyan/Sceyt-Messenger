//
//  MesssagesCollectionView.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 10.01.25.
//

import UIKit

public class MesssagesCollectionView: UICollectionView {
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        self.alwaysBounceVertical = true
        self.showsVerticalScrollIndicator = true
        self.contentInsetAdjustmentBehavior = .never
        self.automaticallyAdjustsScrollIndicatorInsets = false
        self.transform3D = ChatAppearance.Layout.transform3D
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.alwaysBounceVertical = true
        self.showsVerticalScrollIndicator = true
        self.contentInsetAdjustmentBehavior = .never
        self.automaticallyAdjustsScrollIndicatorInsets = false
        self.transform3D = ChatAppearance.Layout.transform3D
    }

    func setBackgroundView(_ backgroundView: UIView?, animated: Bool) {
        self.backgroundView = backgroundView
    }
}
