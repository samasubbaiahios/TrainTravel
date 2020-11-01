//
//  RequestProtocol.swift
//  MyTravelHelper
//
//  Created by Venkata Sama on 01/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

typealias QueryParam = [String: String]

public enum HTTPMethod: String {
    case post   = "POST"
    case get    = "GET"
    case put    = "PUT"
    case delete = "DELETE"
}

public enum HTTPContentType {
    case json, xml, html, multipart(boundary: String), formurlencoded
    
    var contentType: String {
        switch self {
        case .json:
            return "application/json"
        case .xml:
            return "text/xml;charset=utf-8"
        case .html:
            return "text/html;charset=utf-8"
        case .multipart(let boundary):
            return "multipart/form-data; charset=utf-8;  boundary=\(boundary)"
        case .formurlencoded:
            return "application/x-www-form-urlencoded"
        }
    }
}
protocol APIResponseProcessor {
    func convertToConsumableJSON(from responseJSON: JSON) -> JSON
}
protocol RequestProtocol {
    var urlString: String? { get }
    
    var resourcePath: String { get }
    
    var pathParam: String? { get }
    
    var queryParams: QueryParam? { get }
    
    var customRequestHeader: [String: String]? { get set }
    
    var httpMethod: HTTPMethod? { get }
    
    var contentType: HTTPContentType? { get set }
    
    var fullResourcePath: String { get }
    
    var responseProcessor: APIResponseProcessor? { get }
    
    var shouldIgnoreCacheData: Bool { get }
    
    var timeoutInterval: TimeInterval { get set }
    
    var body: Data? { get set }
}

extension RequestProtocol {
    var cachePolicy: NSURLRequest.CachePolicy {
        let cachePolicy: NSURLRequest.CachePolicy = shouldIgnoreCacheData ? .reloadIgnoringLocalCacheData: .useProtocolCachePolicy
        return cachePolicy
    }
    
    var timeoutInterval: TimeInterval {
        return 180
    }
}
