//
//  UIImageView.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 10.01.25.
//

import UIKit

extension UIImageView {
    func setImage(from url: String) async {
        guard let url = URL(string: url) else {
            return
        }

        do {
            let result = try await URLSession.shared.data(from: url)
            let data = result.0
            let image = UIImage(data: data)

            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        } catch {
            print("Failed to download image from url: \(url) with \(error)")
        }
    }
}
