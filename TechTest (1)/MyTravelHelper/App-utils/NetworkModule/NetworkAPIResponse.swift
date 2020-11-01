//
//  NetworkAPIResponse.swift
//  MyTravelHelper
//
//  Created by Venkata Sama on 01/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

final class NetworkAPIResponse {
    let request: RequestProtocol
    let urlResponse: URLResponse?
    let data: Data?
    var error: Error?
    
    // MARK: - Init NetworkAPIResponse
    init(request: RequestProtocol,
         urlResponse: URLResponse? = nil,
         data: Data? = nil,
         error: Error? = nil) {
        self.request = request
        self.urlResponse = urlResponse
        self.data = data
        self.error = error
    }
    class func objCParseData(_ data: Data?) -> Array<Any> {
        let serializationError: Error? = nil
        var courseJSON: [Any]? = nil
        if let data = data {
            courseJSON = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any]
        }
        if serializationError != nil {
            if let serializationError = serializationError {
                print("\n Aborting Task: Failed to serialize into JSON with Error: \(serializationError)\n")
            }
            return []
        }
        return courseJSON ?? []
    }
    
    func asJSON() -> JSON? {
        let response = getResponse(from: data)
        
        if let error = response.error {
            self.error = error
            return nil
        }
        
        return response.responseJSON
    }
    
    // MARK: - JSON Processor
    private func processJSON(from responseData: Data?) -> JSON? {
        guard let responseData = responseData else { return nil }
        
        if let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? JSON {
            if let responseProcessor = self.request.responseProcessor {
                return responseProcessor.convertToConsumableJSON(from: json)
            }
            return json
        }
        return nil
    }
    
    // MARK: - Error Handling
    private func getResponse(from data: Data?) -> (responseJSON: JSON?, error: Error?) {
        if let error = error {
            return (responseJSON: nil, error: error)
        } else {
            // Response is nil
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return (responseJSON: nil, error: error)
            }
            
            // Couldn't process Data
            guard let responseJSON = processJSON(from: data) else {
                return (responseJSON: nil, error: error)
            }
            
            let validStatusCode = (200...299).contains(httpResponse.statusCode)
            
            if !validStatusCode {
                var failureReason = "Unknown error"
                if let response = responseJSON.values.first as? String {
                    failureReason = response
                }
                return (responseJSON: ["message": failureReason], error: error)
                
            } else {
                // No errors
                return (responseJSON: responseJSON, error: nil)
            }
        }
    }
    func createCodableModel<T: Codable>(from json: JSON, of type: T.Type) -> T? {
        var model: T?
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            model = try JSONDecoder().decode(type, from: jsonData)
        } catch {
            print("Could not decode object of type: \(T.self), due to an error=\(error)")
        }
        return model
    }
    
    func createJson<T: Codable>(_ type: T) -> Data? {
        var model: Data?
        do {
            model = try JSONEncoder().encode(type)
        } catch {
            print("Could not decode object of type: \(T.self), due to an error=\(error)")
        }
        return model
    }

}
