//
//  DataManager.swift
//  Metro Navigation
//
//  Created by Anastasia on 01.05.17.
//  Copyright © 2017 Anastasia. All rights reserved.
//

import Foundation
import UIKit

class DataManager {
    
    private var ways: [Way] = []
    private var timeForWay: Int = 0

    
    private init() {}
    static let instance = DataManager()
    
    func getWays () -> [Way] {
        return ways
    }

    func getTime() -> Int {
        return timeForWay
    }
    
    func readInfoFromJson () {
        

        let localURL = Bundle.main.url(forResource: "Kiev", withExtension: "json")
        
        let fileData: Data?
        do {
            fileData = try Data(contentsOf: localURL!)
        } catch {
            print("Read data error")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: fileData!) as? [String: Any],
                
                let lines = json["lines"] as? [[String: Any]] {
                    for line in lines {
                        let color = line["color"] as! String
                        let name = line["name"] as! String
                        
                        var thisLineStations: [Station] = []
                        if let stations = line["stations"] as? [[String: Any]] {
                            for station in stations {
                                let lat = station["lat"] as! Double
                                let lon = station["lon"] as! Double
                                let statName = station["name"] as! String
                                let timeNext = station["timeNext"] as! Int
                                let timePrev = station["timePrev"] as! Int
                                let id = station["id"] as! Int
                               
                                let stat = Station(stationName: statName, stationId: id, x: lat, y: lon, timeN: timeNext, timeP: timePrev)
                                thisLineStations.append(stat)
                             }
                        }
                        
                        ways.append(Way(myStations: thisLineStations, myName: name, myColor: color))
                    }
                }
        } catch {
                print("Error deserializing JSON: \(error)")
        }
        
    }
    
    
    func initWays () {
        
        readInfoFromJson()
        
        if let station1 = ways[0].getStationByName(name: "Zoloti vorota"), let station2 = ways[2].getStationByName(name: "Teatralna") {
            ways[0].transfers.append([station1, station2])
            ways[2].transfers.append([station2, station1])
        }
        
        if let station1 = ways[0].getStationByName(name: "Palats sportu"), let station2 = ways[1].getStationByName(name: "Lva Tolstogo Square") {
            ways[0].transfers.append([station1, station2])
            ways[1].transfers.append([station2, station1])
        }
        
        if let station1 = ways[2].getStationByName(name: "Khreshchatyk"), let station2 = ways[1].getStationByName(name:  "Maidan Nezalaznosti") {
            ways[2].transfers.append([station1, station2])
            ways[1].transfers.append([station2, station1])
        }
        
        
    }
    
    
    func buildWay (from: String, to: String) -> [Way] {
        
        var fromWay: Way?
        var toWay: Way?
        
        var fromStation: Station?
        var toStation: Station?
        
        var newWay: [Way] = []
        
        for way in ways {
            if let station = way.getStationByName(name: from) {
                fromWay = way
                fromStation = station
            }
            
            if let station = way.getStationByName(name: to) {
                toWay = way
                toStation = station
            }
        }


        if fromWay?.name == toWay?.name {
            
            if let way = fromWay, let fromSt = fromStation, let toSt = toStation, let color = fromWay?.color {
                newWay.append(Way(myStations: findPathInOneWay(fromStation: fromSt, toStation: toSt, myWay: way), myName: "", myColor: color))
            }
            
            
        } else {
            
            if let transfers = fromWay?.transfers {
                for item in transfers {
                    if let station1 = fromWay?.getStationByName(name: item[0].name),
                        let station2 = toWay?.getStationByName(name: item[1].name),
                        station2.id != -1,
                        let wayT = toWay,
                        let wayFr = fromWay,
                        let color1 = fromWay?.color,
                        let color2 = toWay?.color {

                        newWay.append(Way(myStations: findPathInOneWay(fromStation: fromStation!, toStation: station1, myWay: wayFr), myName: "", myColor: color1))
                        
                        newWay.append(Way(myStations: findPathInOneWay(fromStation: station2, toStation: toStation!, myWay: wayT), myName: "", myColor: color2))
                        
                        
                        break
                        
                        }
                }
            }
        }
        


        

        
        return newWay
        
    }
    
    func findPathInOneWay (fromStation: Station, toStation: Station, myWay: Way) -> [Station] {
        let fromId = fromStation.id
        let toId = toStation.id
        var way: [Station] = []
    
        var currentStation = Station(with: fromStation)
        
        if fromId > toId {
            for _ in toId...fromId {
                let station = Station(with: currentStation)
                way.append(Station(with: station))
                timeForWay += station.timeToPrevStation
                if var prevStat = station.prev {
                    prevStat = Station(with: prevStat)
                    currentStation = Station(with: prevStat)
                }
            }
 
        } else {
            for _ in fromId...toId {
                let station = Station(with: currentStation)
                way.append(Station(with: station))
                timeForWay += station.timeToNextStation
                if var nextStat = station.next {
                    nextStat = Station(with: nextStat)
                    currentStation = Station(with: nextStat)
                }
            }
        }
        

        return way
    }

    
    func destroyWay() {
     
        timeForWay =  0
    }

}
