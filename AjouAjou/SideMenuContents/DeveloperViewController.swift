//
//  DeveloperViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 10..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit

class DeveloperViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    
    let colors : Colors = Colors()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = colors.colorPrimary
        
        let edgeInsets:CGFloat = 8
        backButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        backButton.layer.cornerRadius = 25
        backButton.layer.shadowOpacity = 0.3
        backButton.layer.shadowRadius = 2
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
    }

    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
