//
//  LocationCell.swift
//  here
//
//  Created by Tommaso Piazza on 09/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import UIKit
import there

typealias LocationCellPlusButtonCallBack = (location:ThereLocation?)->()

class LocationCell: UITableViewCell {


    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var onPlusButtonTapped:LocationCellPlusButtonCallBack?
    
    var location:ThereLocation? {
        
        didSet {
            self.titleLabel.text = location?.address
        }
    }
    
    override func prepareForReuse() {
        self.location = nil
    }
    
    @IBAction func plusButtonTapped(sender:AnyObject) {
    
        if let callBack = onPlusButtonTapped {
        
            callBack(location: self.location)
        }
    }
}