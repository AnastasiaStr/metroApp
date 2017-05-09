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


class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var fromTextField: UITextField!
    
    @IBOutlet weak var metroMap: MKMapView!
    @IBOutlet weak var wayText: UITextView!
    

    //var annotations: [MKAnnotation] = []
    var wayAnnotations: [MKAnnotation] = []
    var noMoreWayAnnotations: [MKAnnotation] = []
    var wayPolyline: CustomPolyline?
  
    var lastGoodMapRect: MKMapRect?
    var manuallyChangingMapRect: Bool = false
    var mapOverlay: MKOverlay?


    override func viewDidLoad() {
        super.viewDidLoad()
        toTextField.delegate = self
        fromTextField.delegate = self
        DataManager.instance.alternativeInit()
        
        wayText.isHidden = true
        metroMap.delegate = self
        
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
            var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
            for station in item.stations {
                
                let annotation = station.annotation
                points.append(annotation.coordinate)
                let polyline = CustomPolyline(coordinates: points, count: points.count)
                polyline.color = item.color
                metroMap.add(polyline)
                metroMap.addAnnotation(annotation)
            }

        }
        
        
        /*
        points = [annotations[12].coordinate, annotations[43].coordinate]
        polyline = CustomPolyline(coordinates: points, count: points.count)
        metroMap.add(polyline)
        
        points = [annotations[26].coordinate, annotations[44].coordinate]
        polyline = CustomPolyline(coordinates: points, count: points.count)
        metroMap.add(polyline)
        
        points = [annotations[11].coordinate, annotations[25].coordinate]
        polyline = CustomPolyline(coordinates: points, count: points.count)
        metroMap.add(polyline)*/
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is CustomPolyline {
            let myLine: CustomPolyline = overlay as! CustomPolyline
            let renderer1 = MKPolylineRenderer(overlay: overlay)
            renderer1.strokeColor = UIColor(hex: myLine.color)
            renderer1.lineWidth = myLine.width
        
            return renderer1
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.black.withAlphaComponent(1)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2
            return renderer
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
                    if let station = way.getStationByName(name: title) {
                        if station.isInWay == true {
                            annotationView.image = UIImage(named: "yellow")
                        } else {
                            annotationView.image = UIImage(named: way.name)
                        }
                    }
                }
            }
        }
        
        return annotationView
    }

    
    func makePath () {
        
        deleteOldWay()
        
        let toName = toTextField.text ?? ""
        let fromName = fromTextField.text ?? ""
        
        DataManager.instance.buildWay(from: toName, to: fromName)
        let way = DataManager.instance.getNewWay()
        
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        wayAnnotations = []
        for item in way {
            points.append(item.annotation.coordinate)
            wayAnnotations.append(item.annotation)
        }
        
        wayPolyline = CustomPolyline(coordinates: points, count: points.count)
        wayPolyline?.color = "ffff00"
        wayPolyline?.width = 5.0
        if let polyline = wayPolyline {
            metroMap.add(polyline)
        }
        
        metroMap.removeAnnotations(wayAnnotations)
        metroMap.addAnnotations(wayAnnotations)
        
        wayText.text = ""
        wayText.text.append(DataManager.instance.getWayText())


        metroMap.reloadInputViews()
        wayText.isHidden = false

    }

    
    func deleteOldWay () {
        DataManager.instance.destroyWay()
        noMoreWayAnnotations.append(contentsOf: wayAnnotations)
        metroMap.removeAnnotations(wayAnnotations)
        if let polyline = wayPolyline {
            metroMap.remove(polyline)
        }
        metroMap.addAnnotations(noMoreWayAnnotations)
        
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
        
        if fromTextField.text != "" && toTextField.text != "" {
           makePath()
        }
    }
}

class CustomPolyline: MKPolyline {
    
    var color = "000000"
    var width: CGFloat = 4.0
}





