//    The MIT License (MIT)
//
//    Copyright (c) <2015> <Tommaso Piazza>
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

import UIKit
import MapKit
import there
import CoreData

class DetailViewController: UIViewController, ThereClientSettable, ItinerarySettable, ManagedObjectContextSettable, MKMapViewDelegate {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var thereClient:ThereClient!
    var managedObjectContext: NSManagedObjectContext!
    
    
    var polyLine:MKPolyline!
    var polyLineRenderer:MKPolylineRenderer!
    var pinAnnotations = [StopAnnotation]()
    
    var itinerary:Itinerary?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.mapView.delegate = self
        self.requestRoute(self.itinerary)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editItineray:")
    }
    
    private func requestRoute(itinerary:Itinerary?) {
        
        if let itinerary = itinerary  {
            
            if let stops = itinerary.stops {
            
                var stopsArray = Array(stops)
                stopsArray.sort {
                    
                    $0.number < $1.number
                }
                
                var wayPoints = [(Double, Double)]()
                
                for stop in stopsArray {
                    
                    wayPoints = wayPoints + [(stop.lat, stop.lon)]
                }
                
                self.thereClient.routeWithWayPoins(wayPoints, mode:ThereRoutingMode.FastestCar) { (wayPoints, error) in
                    
                    if (error != nil) {
                        self.showError(error!)
                    }
                    else {
                        self.placePinsOnMap(wayPoints!)
                        self.drawRoute()
                        self.centerMap()
                    }
                }
                
            }

        }
    }
    
    private func showError(error:NSError) {
        //Boring lauzy pop up
    }
    
    private func placePinsOnMap(wayPoints:[ThereWayPoint]){
        
        self.mapView.removeAnnotations(self.pinAnnotations)
        self.pinAnnotations = [StopAnnotation]()
        
        if wayPoints.count > 0 {
            
            for i in 0...wayPoints.count-1 {
                
                let annotation = StopAnnotation(latitude: wayPoints[i].lat, longitude: wayPoints[i].lon, title: "Stop: \(i)", subtitle: "\(wayPoints[i].lat), \(wayPoints[i].lon)")
                self.pinAnnotations += [annotation]
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func drawRoute(){
        
        self.mapView.removeOverlay(self.polyLine)
        
        var coordinates:[CLLocationCoordinate2D] = self.pinAnnotations.reduce([CLLocationCoordinate2D]()) { (array, annotation) in
            
            return array + [annotation.coordinate]
        }
        
        self.polyLine = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        self.polyLineRenderer = MKPolylineRenderer(overlay: self.polyLine)
        self.polyLineRenderer.lineWidth = 5
        self.polyLineRenderer.strokeColor = UIColor.redColor()
        self.polyLineRenderer.alpha = 0.7
        
        self.mapView.addOverlay(self.polyLine)
    }
    
    private func centerMap() {
        
        if let firstAnnotation = self.pinAnnotations.first {
            
            self.mapView.centerCoordinate = firstAnnotation.coordinate
        }
    }
    
    
    func editItineray(sender: AnyObject) {
        
        if let viewController:ItineraryViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("ItineraryViewController") as? ItineraryViewController) {
            
            viewController.managedObjectContext = self.managedObjectContext
            viewController.thereClient = self.thereClient
            viewController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            viewController.itinerary = itinerary
            viewController.delegate = self
            
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
}


extension DetailViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        return self.polyLineRenderer
    }
}

extension DetailViewController : ItineraryViewControllerDelegate {
    
    func itineraryViewController(viewController: ItineraryViewController, didSaveItinerary itinerary: Itinerary) {
        self.itinerary = itinerary
        self.requestRoute(self.itinerary)
    }
}
