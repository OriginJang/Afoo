//
//  CustomerManual3ViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 17..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit

class CustomerManual3ViewController: UIViewController,BEMCheckBoxDelegate {


    @IBOutlet weak var checkButton: BEMCheckBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkButton.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextPageButtonAction(_ sender: Any) {
        if checkButton.on{
            
        }else{
            let alert = UIAlertController(title: "알림", message: "개인정보 취급방침을 읽고 확인해주세요.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
            
                self.present(alert, animated: true, completion: nil)
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "customerFirstSegue"{
            guard let nextVC = segue.destination as? UpdateInformCustomerViewController else { return }
            nextVC.isFirst = true
        }
    }
        
    

}
