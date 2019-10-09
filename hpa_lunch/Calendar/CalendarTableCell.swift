//
//  CalendarTableCell.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 11/16/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit

class CalendarTableCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var calText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
