//
//  OptionsTableViewCell.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/31/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

class OptionsTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionsSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        selectionStyle = .None
    }

}
