//
//  TestDataLoader.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-02.
//

import Foundation

struct TestDataLoader {
    static func load<T: Decodable>(_ filename: String, as type: T.Type) -> T {
        let bundle = Bundle(for: TestBundleLocator.self)
        
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("❌ Could not find \(filename).json in test bundle")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("❌ Failed to decode \(filename).json: \(error)")
        }
    }
}
