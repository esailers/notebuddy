//
//  FlickrCollectionViewCell.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/25/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

class FlickrCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var flickrImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Configurations
    
    override func awakeFromNib() {
        activityIndicator.color = UIColor.lightGray
    }
    
}
