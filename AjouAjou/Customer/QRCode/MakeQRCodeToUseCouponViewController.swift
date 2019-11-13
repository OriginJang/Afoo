//
//  MakeQRCodeToUseCouponViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 6..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase

class MakeQRCodeToUseCouponViewController: UIViewController {
    @IBOutlet weak var codeView: UIImageView!
    
    var filter: CIFilter!
    var coupon:Coupon = Coupon()
    let uid = Auth.auth().currentUser?.uid
    let ref: DatabaseReference = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let now = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        let stringDate = dateFormatter.string(from: now as Date)
        
        let qrCodeMsg:String = "\(uid!)=\(coupon.getStoreCode())=\(stringDate)"
        let data = qrCodeMsg.data(using: .ascii, allowLossyConversion: false)
        filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 100, y: 100)
        
        let fImage = UIImage(ciImage: (filter.outputImage?.transformed(by: transform))!)
        codeView.image = fImage
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.ref.child("users/customer/\(uid!)/storage/\(coupon.getStoreCode())").observe(.childChanged) { (snapshot) in
            let check = snapshot.key
            if check == "usage"{
                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true)
            }
            
        }
    }
    @IBAction func checkButtonAction(_ sender: Any) {
        
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        ref.removeAllObservers()
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
