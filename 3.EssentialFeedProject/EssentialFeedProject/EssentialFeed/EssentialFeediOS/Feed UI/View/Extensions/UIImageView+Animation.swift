//
//  UIImageView+Animation.swift
//  EssentialFeediOS
//
//  Created by Fardan Akhter on 05/05/2023.
//

import Foundation
import UIKit

extension UIImageView {
    func setImageAnimation(_ newImage: UIImage?) {
        image = newImage
        
        guard let _ = image else { return }
        
        self.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1
        })
    }
}
