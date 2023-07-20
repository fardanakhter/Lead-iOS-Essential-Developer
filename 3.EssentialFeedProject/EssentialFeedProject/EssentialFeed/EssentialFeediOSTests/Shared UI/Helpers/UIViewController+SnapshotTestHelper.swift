//
//  UIViewController+SnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 20/07/2023.
//

import UIKit

public extension UIViewController {
    func snapShot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
    }
}
