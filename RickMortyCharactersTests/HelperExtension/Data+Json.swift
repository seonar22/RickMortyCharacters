//
//  Data+Json.swift
//  RickMortyCharactersTests
//
//  Created by MAC on 6/10/23.
//

import Foundation
import XCTest

extension Data {
    
    public static func fromJSON(fileName: String,
                                file: StaticString = #file,
                                line: UInt = #line) throws -> Data {
        
        let bundle = Bundle(for: TestBundleClass.self)
        let url = try XCTUnwrap(bundle.url(forResource: fileName, withExtension: "json"),
                                "Unable to find \(fileName).json. Did you add it to the tests?",
                                file: file, line: line)
        return try Data(contentsOf: url)
    }
}

private class TestBundleClass { }
