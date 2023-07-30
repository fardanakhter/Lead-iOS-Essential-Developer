//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Fardan Akhter on 30/07/2023.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialApp

final class CommentsUIIntegrationTests: FeedUIIntegrationTest {
    
    func test_commentsViewController_hasNavigationTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, commentsTitle, "Comments View title mismatched!")
    }
    
    func test_loadCommentsActions_loadComments() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected to not load comemnts when view is not loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected to load comments when view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected to load comments on user's manual reload")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected to load comments on user's multiple manual reloads")
    }
    
    func test_loadsCommentsActions_showsLoadingIndicator() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected to show loading indicator when view is loaded")
        
        loader.completeCommentsLoadingSuccessfully(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected to hide loading indicator when load comments is completed")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected to show loading indicator when user reloads")
        
        loader.completeCommentsLoadingFailing(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected to hide loading indicator when load comments initiated by user is completed")
    }
    
    func test_loadCompletion_rendersSuccessfullyLoadedComments() {
        let (sut, loader) = makeSUT()
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        
        sut.loadViewIfNeeded()
        expect(sut, toRender: [])
        
        loader.completeCommentsLoadingSuccessfully(with: [comment0, comment1], at: 0)
        expect(sut, toRender: [comment0, comment1])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingSuccessfully(with: [comment0, comment1], at: 1)
        expect(sut, toRender: [comment0, comment1])
    }
    
    func test_loadCompletion_rendersSuccessfullyEmptyCommentsAfterNonEmptyComments() {
        let (sut, loader) = makeSUT()
        let comment = makeComment()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoadingSuccessfully(with: [comment], at: 0)
        expect(sut, toRender: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingSuccessfully(with: [], at: 1)
        expect(sut, toRender: [])
    }
    
    func test_loadCompletion_doesNotChangeLoadedCommentsWhenCompletesWithError() {
        let (sut, loader) = makeSUT()
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        
        sut.loadViewIfNeeded()
        expect(sut, toRender: [])
        
        loader.completeCommentsLoadingSuccessfully(with: [comment0, comment1], at: 0)
        expect(sut, toRender: [comment0, comment1])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingFailing(with: anyError())
        expect(sut, toRender: [comment0, comment1])
    }
    
    func test_loadCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        let exp = expectation(description: "Waiting for load comments completion")
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            loader.completeCommentsLoadingSuccessfully(with: [self.makeComment()], at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helper
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (ListViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsUIComposedWith(commentsLoader: loader)
        trackMemoryLeak(loader, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeComment(message: String = "a message", createdAt: Date = Date(), username: String = "a username") -> ImageComment {
        return ImageComment(id: UUID(), message: message, createdAt: createdAt, username: username)
    }
    
    private func expect(_ sut: ListViewController, toRender comments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        XCTAssertEqual(sut.numberOfCommentViews, comments.count, file: file, line: line)
        comments.enumerated().forEach{ (index, comment) in
            assert(that: sut, render: comment, at: index, file: file, line: line)
        }
    }
    
    private func assert(that sut: ListViewController, render comment: ImageComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.commentView(at: index)
        XCTAssertEqual(view?.messageLabel.text, comment.message, file: file, line: line)
        XCTAssertEqual(view?.usernameLabel.text, comment.username, file: file, line: line)

    }
    
    class LoaderSpy: ImageCommentLoader{
        private var requestCompletions = [(ImageCommentLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            requestCompletions.count
        }
        
        func load(completion: @escaping (ImageCommentLoader.Result) -> Void) {
            requestCompletions.append(completion)
        }

        func completeCommentsLoadingSuccessfully(with images: [ImageComment] = [], at index: Int = 0) {
            requestCompletions[index](.success(images))
        }
        
        func completeCommentsLoadingFailing(with error: Error = anyError(), at index: Int = 0) {
            requestCompletions[index](.failure(error))
        }
    }
}

