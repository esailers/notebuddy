//
//  NoteContentTableViewCell.swift
//  Notebuddy
//
//  Created by Eric Sailers on 9/1/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

class NoteContentTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var noteTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        selectionStyle = .None
    }

}
