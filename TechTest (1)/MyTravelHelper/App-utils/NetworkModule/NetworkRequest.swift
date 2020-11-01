//
//  NetworkRequest.swift
//  MyTravelHelper
//
//  Created by Venkata Sama on 01/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

struct NetworkRequest: RequestProtocol {
    
    var responseProcessor: APIResponseProcessor?
    var urlString: String?
    var contentType: HTTPContentType?
    var httpMethod: HTTPMethod?
    var resourcePath: String
    var pathParam: String?
    var queryParams: [String: String]?
    var customRequestHeader: [String: String]?
    var body: Data?
    private var requestTimeoutInterval: TimeInterval = 180
    var shouldIgnoreCacheData: Bool
    
    init(resourcePath: String,
         httpMethod: HTTPMethod? = .get,
         pathParam: String? = nil,
         requestHeader: [String: String]? = nil,
         queryParams: [String: String]? = nil,
         contentType: HTTPContentType? = .json,
         urlString: String? = nil,
         shouldIgnoreCacheData: Bool = false) {
        self.httpMethod = httpMethod
        self.resourcePath = resourcePath
        self.pathParam = pathParam
        self.queryParams = queryParams
        self.customRequestHeader = requestHeader
        self.urlString = urlString
        self.shouldIgnoreCacheData = shouldIgnoreCacheData
    }
    
    var timeoutInterval: TimeInterval {
        get {
            return requestTimeoutInterval
        } set {
            requestTimeoutInterval = newValue
        }
    }
    
    static func apiRequest(from resourcePath: String, responseProcessor: APIResponseProcessor?=nil) -> NetworkRequest {
        var apiRequest = NetworkRequest(resourcePath: resourcePath)
        apiRequest.responseProcessor = responseProcessor
        return apiRequest
    }
}

extension NetworkRequest {
    public var fullResourcePath: String {
        var path = "\(resourcePath)"
        
        if let param = pathParam {
            path += "/\(param)"
        }
        
        if let queryParam = queryParams {
            path += queryParam.toQueryString().urlEncodedString
        }
        
        return path
    }
    
    func uniqueIdentifier() -> String {
        var uniqueId = resourcePath.replacingOccurrences(of: "/", with: "_")
        
        if let param = pathParam {
            uniqueId += "_\(param)"
        }
        
        if let queryParam = queryParams {
            uniqueId += queryParam.values.joined(separator: "_")
        }
        
        return uniqueId
    }
}
