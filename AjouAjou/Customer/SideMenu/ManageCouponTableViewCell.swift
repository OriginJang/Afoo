//
//  ManageCouponTableViewCell.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 5..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit

class ManageCouponTableViewCell: UITableViewCell {

    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var numOfCouponLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}