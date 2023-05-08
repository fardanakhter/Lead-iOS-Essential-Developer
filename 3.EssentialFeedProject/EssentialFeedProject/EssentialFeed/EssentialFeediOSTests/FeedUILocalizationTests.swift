//
//  FeedUILocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Fardan Akhter on 08/05/2023.
//

import XCTest
@testable import EssentialFeediOS

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

    
    private func allLocalizedStringKeys(in bundle: Bundle, from table: String) -> [String] {
        let defaultLocalization = Locale.current.language.languageCode?.identifier ?? ""
        if let path = bundle.url(forResource: table, withExtension: "strings", subdirectory: nil, localization: defaultLocalization),
           let dictionary = NSDictionary(contentsOf: path) as? [String: String]{
            return dictionary.keys.map{ $0 }
        }
        return []
    }
}
