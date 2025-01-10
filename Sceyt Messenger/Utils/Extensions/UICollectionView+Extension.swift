//
//  UICollectionView+Extension.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 10.01.25.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        let name = String(describing: cellClass.self)
        self.register(cellClass, forCellWithReuseIdentifier: name)
    }

    func dequeueCell<T>(ofType type: T.Type, indexPath path: IndexPath) -> T {
        let clsString = String(describing: T.self)
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: clsString, for: path) as? T else {
            fatalError("Can not dequeue cell \(clsString)") }
        return cell
    }
}
