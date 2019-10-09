//
//  ForumTableCell.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 11/30/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit
import FontAwesome_swift

class ForumTableCell: UITableViewCell {


    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var forumName: UILabel!
    @IBOutlet weak var forumDesc: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        goButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .regular)
        goButton.setTitle(String.fontAwesomeIcon(name: .arrowAltCircleRight), for: .normal)
        goButton.titleLabel?.textAlignment = .center
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = sideView.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if selected {
            sideView.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = sideView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            sideView.backgroundColor = color
        }
    }
}
