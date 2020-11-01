//
//  NetworkManager.swift
//  MyTravelHelper
//
//  Created by Venkata Sama on 01/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

typealias ResponseHandler = ((NetworkAPIResponse) -> Void)

class NetworkManager: NSObject {
    var taskCancelled = false
    private static var sharedManager: NetworkManager!

    public static func shared() -> NetworkManager {
        if let sharedObject = sharedManager {
            return sharedObject
        } else {
            sharedManager = NetworkManager()
            return sharedManager
        }
    }
    
    override private init() {
    }
    /// Initaite API Call
    ///
    /// - Parameters:
    ///    - request: Service Request which abides request protocol
    ///    - completionCallback: Response which has NetworkAPI

    func startLoading(request: RequestProtocol, with completionCallback: @escaping (ResponseHandler)) {
        let urlRequest = URLRequest(request: request)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 180
        let activeSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = activeSession.dataTask(with: urlRequest) { data, urlResponse, error in
            let response = NetworkAPIResponse(request: request, urlResponse: urlResponse, data: data, error: error)
            completionCallback(response)
        }
        task.resume()
        activeSession.finishTasksAndInvalidate()
    }

    
    @discardableResult
    func responseContainsError(_ urlResponse: URLResponse?, error: Error? = nil) -> Bool {
        if let _ = error as NSError? {
            return true
        }
        guard let httpResponse = urlResponse as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                print("httpResponse: \(String(describing: urlResponse))")
                return true
        }
        return false
    }

}

extension NetworkManager: URLSessionDelegate {
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error {
            print ("didBecomeInvalidWithError: \(error)")
        }
    }
}

extension NetworkManager: URLSessionDownloadDelegate {

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        if responseContainsError(downloadTask.response) || self.taskCancelled == true {
            return
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let _ = downloadTask.response as? HTTPURLResponse {
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print(#function)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        responseContainsError(task.response, error: error)
    }
}
