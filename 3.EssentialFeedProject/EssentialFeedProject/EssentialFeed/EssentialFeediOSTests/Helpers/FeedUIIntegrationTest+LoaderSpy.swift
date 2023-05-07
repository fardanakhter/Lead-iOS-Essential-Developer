//
//  FeedUIIntegrationTest+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 08/05/2023.
//

import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTest {
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        //MARK: - FeedLoader
        private var requestCompletions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            requestCompletions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            requestCompletions.append(completion)
        }
        
        func completeFeedLoadingSuccessfully(with images: [FeedImage] = [], at index: Int = 0) {
            requestCompletions[index](.success(images))
        }
        
        func completeFeedLoadingFailing(with error: Error = anyError(), at index: Int = 0) {
            requestCompletions[index](.failure(error))
        }
        
        // MARK: - FeedImageDataLoaderTask
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelClosure: () -> Void
            func cancel() {
                cancelClosure()
            }
        }
        
        // MARK: - FeedImageDataLoader
        private var imageLoadCompletion = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedImageURLs: [URL] {
            imageLoadCompletion.map{ $0.url }
        }
        var cancelledImageLoadURLs = [URL]()
        
        func load(_ url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageLoadCompletion.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageLoadURLs.append(url)
            }
        }
        
        func completeImageLoadingFailing(with error: Error = anyError(), at index: Int = 0) {
            imageLoadCompletion[index].completion(.failure(error))
        }
        
        func completeImageLoadingSuccessfully(with imageData: Data, at index: Int = 0) {
            imageLoadCompletion[index].completion(.success(imageData))
        }
    }
}
