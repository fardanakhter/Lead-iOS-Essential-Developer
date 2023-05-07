//
//  FeedUIIntegrationTest+SimulateViewActions.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 08/05/2023.
//

import UIKit

extension UIButton {
    func simulateRetryImageLoad() {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
    
}
