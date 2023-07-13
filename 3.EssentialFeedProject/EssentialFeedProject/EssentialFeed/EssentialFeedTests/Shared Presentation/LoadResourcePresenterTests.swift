//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Fardan Akhter on 13/07/2023.
//

import XCTest
import EssentialFeed

final class LoadResourcePresenterTests: XCTestCase {
    
    func test_init_doesnotRequestEvent() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [], "Expected no event on init")
    }
    
    func test_didStartLoading_startsDisplayingLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingResource()
        
        XCTAssertEqual(view.messages, [.display(isLoading: true)], "Expected display loading event")
    }
    
    func test_didCompleteLoading_displaysResourceAndStopsDisplayingLoading() {
        let (sut, view) = makeSUT(mapper: { resource in
            resource + " view model"
        })
        
        let resource = "resource"
        
        sut.didCompleteLoading(with: resource)
        
        XCTAssertEqual(view.messages, [.display(resourceViewModel: "resource view model"), .display(isLoading: false)], "Expected display resource and loading events")
    }
    
    func test_didCompleteLoadingWithError_stopsDisplayingLoading() {
        let (sut, view) = makeSUT()
        
        sut.didCompleteLoadingResource(with: anyError())
        
        XCTAssertEqual(view.messages, [.display(isLoading: false)], "Expected display loading event")
    }
    
    // MARK: - Helper
    
    private func makeSUT(mapper: @escaping LoadResourcePresenter.Mapper = {_ in "any"}, file: StaticString = #file, line: UInt = #line) -> (sut: LoadResourcePresenter, view: ResourceViewSpy) {
        let view = ResourceViewSpy()
        let sut = LoadResourcePresenter(view: view, loadingView: view, mapper: mapper)
        trackMemoryLeak(view, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ResourceViewSpy: ResourceView, ResourceLoadingView {
        private(set) var messages = Set<Message>()
        
        enum Message: Hashable {
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
    }
}
