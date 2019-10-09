//
//  HomeWorkViewCell.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 11/5/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit

class HomeworkTableCell: UITableViewCell {

    @IBOutlet weak var completeSwitch: UISwitch!
    @IBOutlet weak var courseLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
