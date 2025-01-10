//
//  UIImageView.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 10.01.25.
//

import UIKit

extension UIImageView {
    func setImage(from path: String) async {
        guard let url = URL(string: path) else {
            return
        }

        do {
            var image: UIImage?
            if path.contains("http") {
                let result = try await URLSession.shared.data(from: url)
                let data = result.0
                image = UIImage(data: data)
            } else {
                let imageData = try Data(contentsOf: URL(fileURLWithPath: path))
                image = UIImage(data: imageData)
            }
           
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        } catch {
            print("Failed to download image from url: \(url) with \(error)")
        }
    }
}
