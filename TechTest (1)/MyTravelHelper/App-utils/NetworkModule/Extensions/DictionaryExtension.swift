//
//  DictionaryExtension.swift
//  MyTravelHelper
//
//  Created by Venkata Sama on 01/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

extension Dictionary {
    
    func rawData(options opt: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) throws -> Data {
        guard JSONSerialization.isValidJSONObject(self) else {
            throw NSError(domain: "JSON", code: 10_001, userInfo: ["object": self])
        }
        
        return try JSONSerialization.data(withJSONObject: self, options: opt)
    }
    
    static func from(_ data: Data, options opt: JSONSerialization.ReadingOptions = []) throws -> JSON? {
        if let dictionary: JSON = try JSONSerialization.jsonObject(with: data, options: opt) as? JSON {
            return dictionary
        }
        
        return nil
    }
    
    mutating func update(other: Dictionary) {
        for (key, value) in other {
            self.updateValue(value, forKey: key)
        }
    }
}

extension Dictionary where Key == String, Value == String {
    func toQueryString() -> String {
        var queryString: String = "?"
        
        if !self.keys.isEmpty {
            for (key, value) in self {
                queryString += String(format: "%@=%@&", key, value)
            }
        }
        
        return String(queryString.dropLast())
    }
}

extension String {
    func sanatisedDrawingsSearchString() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var uppercasingFirst: String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    var lowercasingFirst: String {
        return prefix(1).lowercased() + dropFirst()
    }
    
    var camelCasedString: String {
        return self.components(separatedBy: " ")
            .map { return $0.lowercased().uppercasingFirst }
            .joined(separator: " ")
    }
    
    var urlEncodedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}
