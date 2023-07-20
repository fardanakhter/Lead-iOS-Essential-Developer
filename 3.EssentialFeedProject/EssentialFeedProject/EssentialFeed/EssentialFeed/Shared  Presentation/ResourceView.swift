//
//  ResourceView.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 13/07/2023.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}
