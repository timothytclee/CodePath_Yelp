//
//  SwitchCell.swift
//  Yelp
//
//  Created by Timothy Lee on 9/23/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    optional func switchCell(SwitchCell: SwitchCell, didChangeValue value: Bool)
}


class SwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    
    weak var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        onSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func switchValueChanged() {
        delegate?.switchCell?(self, didChangeValue: onSwitch.on)
    }

}
