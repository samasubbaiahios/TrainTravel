//
//  JSONObject.swift
//  MyTravelHelper
//
//  Created by Venkata Sama on 01/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

enum JSONValueType: Int {
    case string, number, boolean, date, array, dictionary, null, unknown
}

struct JSONObject {

}

extension JSONObject {
    func stringValue() -> String? {
        return ""
    }
}
