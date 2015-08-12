//
//  StopsHeaderView.swift
//  here
//
//  Created by Tommaso Piazza on 10/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import UIKit

class StopsHeaderView: UITableViewHeaderFooterView {

    var label:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addLabel()
        self.setupConstraints()

    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func addLabel() {
        
        self.label = UILabel()
        self.label.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(self.label)
    }
    
    private func setupConstraints() {
    
        let hAlignConstraint = NSLayoutConstraint(item: self.label!,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.contentView,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0)
        
        let vAlignConstraint = NSLayoutConstraint(item: self.label!,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.contentView,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0)
        
        self.addConstraints([hAlignConstraint, vAlignConstraint])
    }
    
    override func intrinsicContentSize() -> CGSize {
        
        var labelSize = self.label.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return CGSizeMake(UIViewNoIntrinsicMetric, labelSize.height)
    }

}
