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
import CoreData
import there

protocol ItineraryViewControllerDelegate : class {

    func itineraryViewController(viewController:ItineraryViewController, didSaveItinerary itinerary:Itinerary)
}

class ItineraryViewController: UIViewController, ManagedObjectContextSettable, ThereClientSettable, ItinerarySettable {

    var managedObjectContext: NSManagedObjectContext!
    var thereClient:ThereClient!
    var itinerary:Itinerary?
    
    weak var delegate:ItineraryViewControllerDelegate?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    weak var stopsViewController:StopsTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let displayName = self.itinerary?.displayName {
            self.nameTextField.text = displayName
        }
    }
    
    @IBAction func doneTapped(sender: AnyObject) {
        

        if count(self.nameTextField.text) == 0 && self.stopsViewController.locationsInItinerary.count > 0 {
            
            self.showMissingItineraryNameAlert()
        }
        else if count(self.nameTextField.text) == 0  && self.stopsViewController.locationsInItinerary.count == 0 {
            self.dismiss()
        }
        else {
            
            self.saveItinerary(self.itinerary)
            self.dismiss()
        }
    }
    
    private func saveItinerary(itinerary:Itinerary?) {
        
        if let itinerary = itinerary {
        
            itinerary.managedObjectContext?.deleteObject(itinerary)

            if let updatedItineraryDesc = NSEntityDescription.entityForName(Itinerary.entityName, inManagedObjectContext: self.managedObjectContext) {
                
                let newItinerary = Itinerary(entity: updatedItineraryDesc, insertIntoManagedObjectContext: self.managedObjectContext)
                
                let maybeStops:[Stop?] = self.stopsViewController.locationsInItinerary.map { (location) -> Stop? in
                    
                    if let newStopDescription = NSEntityDescription.entityForName(Stop.entityName, inManagedObjectContext: self.managedObjectContext) {
                        
                        var stop = Stop(entity:newStopDescription, insertIntoManagedObjectContext:self.managedObjectContext)
                        stop.displayName = location.address
                        stop.lat = location.wayPoint.lat
                        stop.lon = location.wayPoint.lon
                        stop.itinerary = newItinerary
                        stop.createdAt = NSDate()
                        
                        return stop
                    }
                    
                    return nil
                }
                
                let justStops = maybeStops.filter { $0 != nil }.map{$0!}
                let numStops = justStops.count
                
                if (numStops > 0 ) {
                    
                    for i in 0...numStops-1 {
                        justStops[i].number = i
                        justStops[i].itinerary = newItinerary
                    }
                }
                
                newItinerary.stops = Set<Stop>(justStops)
                newItinerary.createdAt = NSDate()
                newItinerary.displayName = self.nameTextField.text
                if self.managedObjectContext.saveOrRollBack() {
                    
                    self.delegate?.itineraryViewController(self, didSaveItinerary: newItinerary)
                }
            }
        }
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        
        if self.stopsViewController.tableView.editing {
            
            self.stopsViewController.tableView.setEditing(false, animated:true)
            self.editButton.setTitle(NSLocalizedString("itinerary.edit.editTitle", comment:""), forState:UIControlState.Normal)
        }
        else {
            self.editButton.setTitle(NSLocalizedString("itinerary.edit.doneTitle", comment:""), forState:UIControlState.Normal)
            self.stopsViewController.tableView.setEditing(true, animated:true)
        }
    }
    
    private func showMissingItineraryNameAlert() {
    
        let alertTitle = NSLocalizedString("itinerary.add.incomplete.title", comment:"")
        let alertMessage = NSLocalizedString("itinerary.add.incomplete.message", comment:"")
        let alertCancel = NSLocalizedString("itinerary.add.incomplete.cancel", comment:"")

        let alertView = UIAlertView(title: alertTitle, message: alertMessage, delegate: nil, cancelButtonTitle:alertCancel)
        
        alertView.show()
    }
    
    private func dismiss() {
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "StopsList") {
            self.stopsViewController = segue.destinationViewController as?  StopsTableViewController
            self.stopsViewController.thereClient = self.thereClient
            self.stopsViewController.managedObjectContext = self.managedObjectContext
            self.stopsViewController.itinerary = self.itinerary
        }
    }
}
