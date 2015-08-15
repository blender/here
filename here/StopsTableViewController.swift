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

class StopsTableViewController: UITableViewController, ThereClientSettable, ManagedObjectContextSettable, ItinerarySettable {

    let searchController = UISearchController(searchResultsController: nil)
    var thereClient:ThereClient!
    var managedObjectContext:NSManagedObjectContext!
    var itinerary:Itinerary? {
        
        didSet {
            
            self.extractLocationsFromItinerary(self.itinerary)
        }
    }
    
    var locationsFromSearch:[ThereLocation] = [ThereLocation]()
    var locationsInItinerary:[ThereLocation] = [ThereLocation]()
    
    private var displayLocations:[ThereLocation] {
        
        get {
            let searchLocationsSet = Set<ThereLocation>(self.locationsFromSearch)
            let existingLocationsSet = Set<ThereLocation>(self.locationsInItinerary)
            
            let resultSet = searchLocationsSet.subtract(existingLocationsSet)
            return Array<ThereLocation>(resultSet)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.registerClass(StopsHeaderView.self, forHeaderFooterViewReuseIdentifier: "stopsHeader")
        self.setupSearchController()
    }
    
    private func setupSearchController() {
    
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.barTintColor = UIColor.whiteColor()
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.sizeToFit()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return self.displayLocations.count
        case 1:
            return self.locationsInItinerary.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as! LocationCell
            self.configureCell(cell, atIndexPath: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("stopCell", forIndexPath: indexPath) as! UITableViewCell
            self.configureCell(cell, atIndexPath: indexPath)
            return cell
        }
    }
    
    private func configureCell(cell:UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        switch(indexPath.section){
            
        case 0:
            var locationCell = cell as? LocationCell
            locationCell?.location = self.displayLocations[indexPath.row]
            locationCell?.onPlusButtonTapped = { [weak self] maybeLocation in
            
                if let strongSelf = self, let location = maybeLocation  {
                    
                    strongSelf.locationsInItinerary =  strongSelf.locationsInItinerary + [location]
                    strongSelf.tableView.reloadData()
                }
            }
            locationCell?.selectionStyle = UITableViewCellSelectionStyle.None
            locationCell?.showsReorderControl = false
        case 1:
            cell.textLabel?.text = self.locationsInItinerary[indexPath.row].address
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.showsReorderControl = true
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let stopsHeader:StopsHeaderView = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("stopsHeader") as! StopsHeaderView
        let label = stopsHeader.label
        stopsHeader.contentView.backgroundColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        label.textColor = UIColor.whiteColor()
        
        switch section {
        
        case 0:
            label.text = NSLocalizedString("stops.table.header.fromSearch", comment: "")
        case 1:
            label.text = NSLocalizedString("stops.table.header.inItinerary", comment: "")
        default:
            break
        }
        
        // This MUST be done here, otherwise section header and table header (the seachBar) will
        // hide eachother in the view hierachy. Seems like a UIKit but to me.
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.sizeToFit()

        return stopsHeader
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
            
        case 0:
            if let cell = self.tableView.visibleCells()[indexPath.row] as? LocationCell {
                cell.plusButtonTapped(self)
            }
        default:
            break
        }
    }

    
    // MARK: Editing and moving
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return indexPath.section == 1
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.locationsInItinerary.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }

    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        let toLocation = self.locationsInItinerary[toIndexPath.row]
        self.locationsInItinerary[toIndexPath.row] = self.locationsInItinerary[fromIndexPath.row]
        self.locationsInItinerary[fromIndexPath.row] = toLocation
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return indexPath.section == 1
    }
    
    override func tableView(tableView: UITableView,
        targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath,
        toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
     
            if proposedDestinationIndexPath.section != sourceIndexPath.section {
                return sourceIndexPath
            }
            return proposedDestinationIndexPath
    }
    
    private func extractLocationsFromItinerary(itinerary:Itinerary?) {
        
        if let itinerary = itinerary {
            
           if let stops = itinerary.stops {
                
                var stops = Array(itinerary.stops!)
                stops.sort {$0.number < $1.number}
                
                
                let locations = stops.reduce([ThereLocation]()) { (list, stop) -> [ThereLocation] in
                    
                    let location =  ThereLocation(lat: stop.lat, lon: stop.lon, address: stop.displayName)
                    return list + [location]
                }
                
                self.locationsInItinerary = locations
            }
            

        }
    }
    
    private func updateSearchResultsForLocations(locations:[ThereLocation]) {
        
        self.locationsFromSearch = locations
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    private func showError(error:NSError){
        
    }
}

extension StopsTableViewController : UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if count(searchController.searchBar.text) > 1 {
            
            self.thereClient.searchWithTerm(searchController.searchBar.text){ (locations, error) -> () in
                
                if locations?.count > 0 {
                    
                    self.updateSearchResultsForLocations(locations!)
                }
                else if error  != nil {
                    
                    self.showError(error!)
                }
            }
        }
        else {
            
            if (self.locationsFromSearch.count > 0 ) {
                self.updateSearchResultsForLocations([ThereLocation]())
            }
        }
    }
}
