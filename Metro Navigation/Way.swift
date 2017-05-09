//
//  Way.swift
//  Metro Navigation
//
//  Created by Anastasia on 07.05.17.
//  Copyright © 2017 Anastasia. All rights reserved.
//

import Foundation
import UIKit

class Way {
    var stations: [Station] = []
    var dictionaryOfStations: [String: Station] = [:]
    var name: String = ""
    var transfers: [[Station]] = []
    var color: String = ""
    
    init(myStations: [Station], myName: String, myColor: String) {
        stations.append(contentsOf: myStations)
        name = myName
        color = myColor
        makeDictionary()
        makeLinks()
     
    }
    
    func makeDictionary () {
        for item in stations {
            dictionaryOfStations[item.name] = item
        }
    }
    
    func makeLinks () {
        stations[0].next = stations[1]
        stations[stations.count - 1].prev = stations[stations.count - 2]
        for i in 1...stations.count - 2 {
            stations[i].prev = stations[i - 1]
            stations[i].next = stations[i + 1]
        }
    }
    
    func getStationByName (name: String) -> Station? {
        if let station = dictionaryOfStations[name]{
            return station
        }
        return nil
    }
}
