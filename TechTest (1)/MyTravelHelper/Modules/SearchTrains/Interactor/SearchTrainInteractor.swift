//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import XMLParsing

class SearchTrainInteractor: PresenterToInteractorProtocol {
    var _sourceStationCode = String()
    var _destinationStationCode = String()
    var presenter: InteractorToPresenterProtocol?
    static var apiClient: NetworkAPIClient = NetworkAPIClient.create(baseUrl: Constants.urlConstants.kBaseURL)


    func fetchallStations() {
        if Reach().isNetworkReachable() == true {
            var request = NetworkRequest(resourcePath: Constants.urlConstants.kAllStations)
            request.shouldIgnoreCacheData = true
            request.contentType = .xml
            SearchTrainInteractor.apiClient.send(request: request) { (result) in
                let station = try? XMLDecoder().decode(Stations.self, from: result.data!)
                self.presenter!.stationListFetched(list: station!.stationsList)
            }
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }

    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
        if Reach().isNetworkReachable() {            
            var request = NetworkRequest(resourcePath: Constants.urlConstants.kStationInfo)
            request.shouldIgnoreCacheData = true
            request.queryParams = ["StationCode": sourceCode]
            request.contentType = .xml
            SearchTrainInteractor.apiClient.send(request: request) { (response) in
                let stationData = try? XMLDecoder().decode(StationData.self, from: response.data!)
                if let _trainsList = stationData?.trainsList {
                    self.proceesTrainListforDestinationCheck(trainsList: _trainsList)
                } else {
                    self.presenter!.showNoTrainAvailbilityFromSource()
                }
            }
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }
    
    private func proceesTrainListforDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        let today = Date()
        let group = DispatchGroup()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: today)
        
        for index  in 0...trainsList.count-1 {
            group.enter()
            var request = NetworkRequest(resourcePath: Constants.urlConstants.kTrackTrain)
            request.shouldIgnoreCacheData = true
            request.queryParams = ["TrainId": trainsList[index].trainCode, "TrainDate": dateString]
            request.contentType = .xml
            if Reach().isNetworkReachable() {
                SearchTrainInteractor.apiClient.send(request: request) { (movementsData) in
                    let trainMovements = try? XMLDecoder().decode(TrainMovementsData.self, from: movementsData.data!)
                    if let _movements = trainMovements?.trainMovements {
                        let sourceIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
                        let destinationIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
                        let desiredStationMoment = _movements.filter{$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
                        let isDestinationAvailable = desiredStationMoment.count == 1

                        if isDestinationAvailable  && sourceIndex! < destinationIndex! {
                            _trainsList[index].destinationDetails = desiredStationMoment.first
                        }
                    }
                    group.leave()
                }
            } else {
                self.presenter!.showNoInterNetAvailabilityMessage()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            let sourceToDestinationTrains = _trainsList.filter{$0.destinationDetails != nil}
            self.presenter!.fetchedTrainsList(trainsList: sourceToDestinationTrains)
        }
    }
}
