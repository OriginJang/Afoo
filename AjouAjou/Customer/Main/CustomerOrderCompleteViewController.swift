//
//  CustomerOrderCompleteViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 7..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit

class CustomerOrderCompleteViewController: UIViewController {

    let colors = Colors()
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = colors.colorPrimary
        // Do any additional setup after loading the view.
    }
    @IBAction func checkButtonAction(_ sender: Any) {
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
