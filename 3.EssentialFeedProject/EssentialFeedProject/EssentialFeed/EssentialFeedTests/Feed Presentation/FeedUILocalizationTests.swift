//
//  FeedUILocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 08/05/2023.
//

import XCTest
import EssentialFeed

final class FeedUILocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForInAllLocalizations() {
        let table = "Feed"
        let presentationBundle = Bundle(for: FeedViewPresenter.self)
        let alllocalizations = presentationBundle.localizations
        let localizedStringKeys = allLocalizedStringKeys(in: presentationBundle, from: table)
        
        alllocalizations.forEach { localization in
            let pathForLocalization = presentationBundle.path(forResource: localization, ofType: "lproj")!
            let localizationBundle = Bundle(path: pathForLocalization)
            
            localizedStringKeys.forEach { localizedKey in
                let localizedValue = localizationBundle?.localizedString(forKey: localizedKey, value: nil, table: table)
                if localizedValue == localizedKey {
                    XCTFail("Missing key: '\(localizedKey)' in table: '\(table)' for localization: '\(localization)'")
                }
            }
        }
    }
}
