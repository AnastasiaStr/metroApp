//
//  Station.swift
//  Metro Navigation
//
//  Created by Anastasia on 01.05.17.
//  Copyright © 2017 Anastasia. All rights reserved.
//

import Foundation
import MapKit

class Station {
    var id: Int = 0
    var name: String = ""

    var timeToNextStation: Double = 0.0
    var timeToPrevStation: Double = 0.0
    
    var next: Station?
    var prev: Station?
    
    var annotation = MKPointAnnotation()
    var isInWay = false
    
    init(stationName: String = "Kek", stationId: Int = -1, x: Double = 0.0, y: Double = 0.0, timeN: Double = 0.0, timeP: Double = 0.0) {
        name = stationName
        id = stationId
        timeToNextStation = timeN
        timeToPrevStation = timeP
        makeAnnotation(x: x, y: y)
    }
    
    func makeAnnotation (x: Double, y: Double){
        let latitude = x
        let longtitude = y
        let location = CLLocationCoordinate2DMake(latitude, longtitude)
        self.annotation.coordinate = location
        self.annotation.title = self.name
    }
}
