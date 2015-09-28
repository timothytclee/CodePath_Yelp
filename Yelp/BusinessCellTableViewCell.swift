//
//  BusinessCellTableViewCell.swift
//  Yelp
//
//  Created by Timothy Lee on 9/23/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCellTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    
    var business: Business! {
        didSet {
            nameLabel.text = business.name
            thumbnailImageView.setImageWithURL(business.imageURL)
            ratingImageView.setImageWithURL(business.ratingImageURL)
            distanceLabel.text = business.distance
            addressLabel.text = business.address
            categoriesLabel.text = business.categories
            reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbnailImageView.layer.cornerRadius = 3
        thumbnailImageView.clipsToBounds = true
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
