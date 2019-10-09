//
//  CourseCell.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 11/5/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit

class CourseCell: UITableViewCell {
    @IBOutlet weak var timingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
