//
//  NetworkAPIClient.swift
//  MyTravelHelper
//
//  Created by Venkata Sama on 01/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

class NetworkAPIClient {
    
    private var baseUrl: String

    private static var sharedClient: NetworkAPIClient?
    
    private init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    /// Creates Network Client instance
    ///
    /// - Parameters:
    ///    - baseUrl: Base url of APP

    static func create(baseUrl: String) -> NetworkAPIClient {
        let client = NetworkAPIClient(baseUrl: baseUrl)
        NetworkAPIClient.setSharedClient(client)
        return client
    }
    
    /// Creates Network Client instance
    ///
    /// - Parameters:
    ///    -

    public static func shared() -> NetworkAPIClient? {
        if sharedClient != nil {
            return sharedClient
        }
        return nil
    }
    
    public static func setSharedClient(_ client: NetworkAPIClient?) {
        sharedClient = client
    }
    
    public var baseURL: URL? {
        return URL(string: baseUrl)
    }
    /// Invoke API request
    ///
    /// - Parameters:
    ///    - request: Service Request which abides request protocol
    ///    - completionCallback: Response which has NetworkAPI
    func send(request: RequestProtocol, completionCallback: @escaping (ResponseHandler)) {
        NetworkManager.shared().startLoading(request: request, with: completionCallback)
    }
}
