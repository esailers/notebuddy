//
//  NotePhotoTableViewCell.swift
//  Notebuddy
//
//  Created by Eric Sailers on 9/1/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

class NotePhotoTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var notePhotoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        selectionStyle = .none
    }

}
