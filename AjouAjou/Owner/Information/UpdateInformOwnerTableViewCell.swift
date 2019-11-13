//
//  UpdateInformOwnerTableViewCell.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 21..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit

class UpdateInformOwnerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
