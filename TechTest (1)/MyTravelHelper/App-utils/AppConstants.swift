//
//  AppConstants.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation

let PROGRESS_INDICATOR_VIEW_TAG: Int = 10

struct Constants {
    struct urlConstants {
        static let kBaseURL = "http://api.irishrail.ie/realtime/realtime.asmx"
        static let kAllStations = "/getAllStationsXML"
        static let kStationInfo = "/getStationDataByCodeXML"
        static let kTrackTrain = "/getTrainMovementsXML"
    }
}
