//
//  EssentialImageCommentsAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Fardan Akhter on 07/08/2023.
//

import XCTest
import EssentialFeed

final class EssentialImageCommentsAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerAPIGETFeedResult_matchesFixedData() {
        switch getFeedResult() {
        case let .success(images):
            XCTAssertEqual(images[0], expectedImageComment(at: 0))
            XCTAssertEqual(images[1], expectedImageComment(at: 1))
            
        case let .failure(error):
            XCTFail("Expected success with comments, found \(error) instead.")
        
        default:
            XCTFail("Expected success with comments, found nil instead.")
        }
    }
    
    // MARK: - Helpers
    
    private typealias Loader = RemoteLoader<[ImageComment]>
    
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> Loader.Result? {
        let url = URL(string: "https://api.jsonbin.io/v3/qs/64d140638e4aa6225ecc4715")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let loader = Loader(url: url, httpClient: client, mapper: ImageCommentMapper.map)
        trackMemoryLeak(client, file: file, line: line)
        trackMemoryLeak(loader, file: file, line: line)
        
        let exp = expectation(description: "Waits for completion!")
        
        var receivedResult: Loader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 8.0)
        return receivedResult
    }
    
    private func expectedImageComment(at index: Int) -> ImageComment {
        return ImageComment(id: id(at: index), message: message(at: index), createdAt: date(at: index), username: username(at: index))
    }
    
    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
            "E621E1F8-C36C-415A-93FC-0C247A3E6E2F"][index])!
    }
    private func message(at index: Int) -> String {
        return [
            "a comment",
            "another comment"
            ][index]
    }
    
    private func date(at index: Int) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return [
            formatter.date(from: "2022-09-06T08:12:04.338Z")!,
            formatter.date(from: "2022-09-06T08:12:04.338Z")!][index]
    }

    private func username (at index: Int) -> String {
        return ["an author", "another author"][index]
    }
    
}
