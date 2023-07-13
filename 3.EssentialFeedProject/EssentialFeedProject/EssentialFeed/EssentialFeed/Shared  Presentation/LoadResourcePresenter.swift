//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 13/07/2023.
//

import Foundation

public final class LoadResourcePresenter<Resource, View: ResourceView>  {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    
    private let view: View
    private let loadingView: ResourceLoadingView
    private let mapper: Mapper
    
    public init(view: View, loadingView: ResourceLoadingView, mapper: @escaping Mapper) {
        self.view = view
        self.loadingView = loadingView
        self.mapper = mapper
    }
    
    public func didStartLoadingResource() {
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didCompleteLoading(with resource: Resource) {
        view.display(mapper(resource))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didCompleteLoadingResource(with error: Error) {
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}

