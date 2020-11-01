//
//  URLExtension.swift
//  MyTravelHelper
//
//  Created by Venkata Sama on 01/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

extension URL {
    init?(request: RequestProtocol) {
        if let urlString = request.urlString {
            self.init(string: urlString)
        } else if let networkClient = NetworkAPIClient.shared() {
            self.init(string: request.fullResourcePath, relativeTo: networkClient.baseURL)
        }
        
        return nil
    }
    
    @discardableResult
    func append(_ queryItem: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string:  absoluteString) else { return absoluteURL }
        
        // create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // create query item if value is not nil
        guard let value = value else { return absoluteURL }
        let queryItem = URLQueryItem(name: queryItem, value: value)
        
        // append the new query item in the existing query items array
        queryItems.append(queryItem)
        
        // append updated query items array in the url component object
        urlComponents.queryItems = queryItems// queryItems?.append(item)
        
        // returns the url from new url components
        return urlComponents.url!
    }
}
