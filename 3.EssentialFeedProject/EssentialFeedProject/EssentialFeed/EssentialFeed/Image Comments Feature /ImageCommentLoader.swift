//
//  ImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Fardan Akhter on 19/06/2023.
//

import Foundation

public protocol ImageCommentLoader {
    typealias Result = Swift.Result<[ImageComment], Error>
    
    func load(completion: @escaping (ImageCommentLoader.Result) -> Void)
}
