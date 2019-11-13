//
//  ReceiptTableViewCell.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 2..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit

class ReceiptTableViewCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
