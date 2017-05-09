//
//  ViewController.swift
//  Metro Navigation
//
//  Created by Anastasia on 01.05.17.
//  Copyright © 2017 Anastasia. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController {

    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var fromTextField: UITextField!
    
    @IBOutlet weak var metroMap: MKMapView!
    @IBOutlet weak var wayText: UITextView!
    
    
    var wayPolyline: CustomPolyline?
    var waySelectingPolyline: CustomPolyline?
    
    var wayPolylines: [CustomPolyline] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        toTextField.delegate = self
        fromTextField.delegate = self
        metroMap.delegate = self
        
        DataManager.instance.initWays()
        
        wayText.isHidden = true
        wayText.layer.cornerRadius = 4.0
        
        fromTextField.tag = 0
        toTextField.tag = 1
        
        showStations()
        
        let location = CLLocationCoordinate2DMake(50.444850, 30.516071)
        let span = MKCoordinateSpanMake(0.2, 0.2)
        let region = MKCoordinateRegion(center: location, span: span)
        metroMap.setRegion(region, animated: true)
        
    }

    
    func showStations () {
        for item in DataManager.instance.getWays() {
            
            for transfer in item.transfers {
                var crossingPoints: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
                for station in transfer {
                    let annotation = station.annotation
                    crossingPoints.append(annotation.coordinate)
                }
                let polyline = CustomPolyline(coordinates: crossingPoints, count: crossingPoints.count)
                polyline.color = "#00000080"
                polyline.width = 3.0
                metroMap.add(polyline)
            }
            
            let stations = item.stations
            var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()

            
            for station in stations {

                let annotation = station.annotation
                points.append(annotation.coordinate)
                metroMap.addAnnotation(annotation)
                
                
            }
            
            let polyline = CustomPolyline(coordinates: points, count: points.count)
            polyline.color = item.color
            metroMap.add(polyline)

            

            
            for coordinate in points {
                var coordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
                coordinates.append(coordinate)
                let pol = CustomPolyline(coordinates: coordinates, count: coordinates.count)
                pol.width = 10.0
                pol.color = item.color
                metroMap.add(pol)
            }
        }
    }
    
    func setTextOfWay (ways: [Way]) {
        wayText.text = ""
        var textOfWay: NSMutableAttributedString?
        textOfWay = NSMutableAttributedString(string: "Ride \(ways[0].stations.count - 1) stations to ", attributes: [:])
        
        let nameOfStation = Utils.getAttributedText(inputText: "\(ways[0].stations[ways[0].stations.count - 1].name) station. ", location: 0, length: ways[0].stations[ways[0].stations.count - 1].name.characters.count, color: UIColor(hexString: ways[0].color)!)
        
        textOfWay?.append(nameOfStation)
        
        if ways.count == 1 {
            let addText = NSMutableAttributedString(string: "You do not need to change the train. ", attributes: [:])
            textOfWay?.append(addText)
        } else {
            var addText = NSMutableAttributedString(string: "Then cross to ", attributes: [:])
            textOfWay?.append(addText)
            addText = Utils.getAttributedText(inputText: "\(ways[1].stations[0].name) station to change line and ride \(ways[1].stations.count) stations ", location: 0, length: ways[1].stations[0].name.characters.count, color: UIColor(hexString: ways[1].color)!)
            textOfWay?.append(addText)
            
            addText = Utils.getAttributedText(inputText: "\(ways[1].stations[ways[1].stations.count - 1].name) station. ", location: 0, length: ways[1].stations[ways[1].stations.count - 1].name.characters.count, color: UIColor(hexString: ways[1].color)!)
            textOfWay?.append(addText)
        }
        
        let timeText = NSMutableAttributedString(string: "It will take near \(DataManager.instance.getTime()) minutes. ", attributes: [:])
        
        textOfWay?.append(timeText)
        wayText.attributedText = textOfWay
    }
    

    func makePath () {
        
        deleteOldWay()
        
        let toName = toTextField.text ?? ""
        let fromName = fromTextField.text ?? ""
        
        let ways = DataManager.instance.buildWay(from: toName, to: fromName)
        
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()

        for way in ways {
            points = []
            for item in way.stations {
                let annotation = item.annotation
                points.append(annotation.coordinate)

            }
            
            waySelectingPolyline = CustomPolyline(coordinates: points, count: points.count)
            waySelectingPolyline?.color = "#000000ff"
            waySelectingPolyline?.width = 8.0
            if let polyline = waySelectingPolyline {
                metroMap.add(polyline)
                wayPolylines.append(polyline)
            }
            
            for coordinate in points {
                var coordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
                coordinates.append(coordinate)
                let polBlack = CustomPolyline(coordinates: coordinates, count: coordinates.count)
                polBlack.width = 13.0
                polBlack.color = "#000000ff"
                metroMap.add(polBlack)
                wayPolylines.append(polBlack)
                
                let polColor = CustomPolyline(coordinates: coordinates, count: coordinates.count)
                polColor.width = 10.0
                polColor.color = way.color
                metroMap.add(polColor)
                wayPolylines.append(polColor)
                
            }
            
            wayPolyline = CustomPolyline(coordinates: points, count: points.count)
            wayPolyline?.color = way.color
            wayPolyline?.width = 4.0
            if let polyline = wayPolyline {
                metroMap.add(polyline)
                wayPolylines.append(polyline)
            }
        
        }
        

        setTextOfWay(ways: ways)
        metroMap.reloadInputViews()
        wayText.isHidden = false

    }

    
    func deleteOldWay () {
        DataManager.instance.destroyWay()
        
        for item in wayPolylines {
            metroMap.remove(item)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is CustomPolyline {
            let myLine: CustomPolyline = overlay as! CustomPolyline
            let renderer1 = MKPolylineRenderer(overlay: overlay)
            renderer1.strokeColor = UIColor(hexString: myLine.color)
            renderer1.lineWidth = myLine.width
            
            return renderer1
        }
        
        return MKOverlayRenderer()
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "Identifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            
            for way in DataManager.instance.getWays() {
                if let title = annotation.title as? String {
                    if way.getStationByName(name: title) != nil {
                        let image = UIImage(named: way.name)?.alpha(0)
                        annotationView.image = image
                    }
                }
            }
        }
        
        return annotationView
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
        let transitionObj = TransitionObject(text: textField.text ?? "", textFieldTag: textField.tag)
        performSegue(withIdentifier: Utils.TableViewSegue, sender: transitionObj)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Utils.TableViewSegue {
            let destination = segue.destination as! TableViewController
            let transitionObj = sender as? TransitionObject
            
            destination.searchText = transitionObj?.text
            destination.textFieldTag = transitionObj?.textFieldTag
            destination.delegate = self
        }
        
    }
}

extension ViewController: MyTableViewDelegate {
    func setData(_ data: String, to tag: Int) {
        
        switch tag {
        case 0:
            fromTextField.text = data
        case 1:
            toTextField.text = data
        default:
            break
        }
        
        if fromTextField.text == toTextField.text {
            wayText.text = ""
            wayText.isHidden = false
            deleteOldWay()
            wayText.text.append("You are already here.")
        } else if fromTextField.text != "" && toTextField.text != "" {
           makePath()
        }
    }
}

class CustomPolyline: MKPolyline {
    
    var color = "#00000030"
    var width: CGFloat = 4.0
}





