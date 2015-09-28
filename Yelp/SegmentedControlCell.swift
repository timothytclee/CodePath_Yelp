//
//  SegmentedControlCell.swift
//  Yelp
//
//  Created by Timothy Lee on 9/25/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SegmentedControlCellDelegate {
    optional func segmentedControlCell(segmentedControlCell: SegmentedControlCell, didChangeValue value: Int)
}


class SegmentedControlCell: UITableViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    weak var delegate: SegmentedControlCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.addTarget(self, action: "segmentedControlChanged", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func segmentedControlChanged() {
        delegate?.segmentedControlCell?(self, didChangeValue: segmentedControl.selectedSegmentIndex)}

}
