//
//  Secrets.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-09-18.
//

import Foundation


class Secrets {
    static var openAIKey: String {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["OPENAI_API_KEY"] as? String {
            return key
        }
        return ""
    }
}
