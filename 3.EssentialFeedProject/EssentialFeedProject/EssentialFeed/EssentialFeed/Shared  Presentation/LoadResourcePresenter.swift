//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 13/07/2023.
//

import Foundation

// Load Resource

public protocol ResourceView {
    func display(_ viewModel: String)
}


// Loading

public protocol ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

public struct ResourceLoadingViewModel {
    public let isLoading: Bool
}


// Generic Presenter

public final class LoadResourcePresenter {
    private let view: ResourceView
    private let loadingView: ResourceLoadingView
    private let mapper: Mapper
    
    public typealias Mapper = (String) -> String
    
    public init(view: ResourceView, loadingView: ResourceLoadingView, mapper: @escaping Mapper) {
        self.view = view
        self.loadingView = loadingView
        self.mapper = mapper
    }
    
    public func didStartLoadingResource() {
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didCompleteLoading(with resource: String) {
        view.display(mapper(resource))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didCompleteLoadingResource(with error: Error) {
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}

