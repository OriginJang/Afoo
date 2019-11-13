//
//  OwnerMainDetailViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 3..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class OwnerMainDetailViewController: UIViewController {

    
    @IBOutlet weak var dtimeLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var orderMenuLabel: UILabel!
    
    let ref: DatabaseReference = Database.database().reference()
    var refHandle: DatabaseHandle?
    
    var dtime:String = ""
    var orderMenu:String = ""
    var orderNumber:String = ""
    var couponKey:String = ""
    var storeCode:String = ""
    
    var distributedCoupon:DistributedCoupon = DistributedCoupon()
    
    let waitingOrder:WaitingOrder = WaitingOrder()
    
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var temp = distributedCoupon.getDtime()
        
        if temp != "" {
            let range = temp.startIndex..<temp.index(temp.startIndex, offsetBy: 14)
            temp.removeSubrange(range)
            orderNumber = temp.components(separatedBy: ["-",":"," "]).joined()
        }
        
        
        orderMenu = orderedMuneToString(orderedMenu: self.distributedCoupon.getOrderedMenu())
        
        dtimeLabel.text = dtime
        orderMenuLabel.text = orderMenu
        orderNumberLabel.text = orderNumber
        // Do any additional setup after loading the view.
    }

    
    func orderedMuneToString(orderedMenu:[String:Int]) -> String {
        if !orderedMenu.isEmpty{
            var resultString:String = ""
            for (key, value) in orderedMenu{
                resultString += "\(key)=\(value),"
            }
            resultString.removeLast()
            return resultString
        }
        return "선택된 메뉴가 없습니다."
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func completeOrderButtomAction(_ sender: Any) {
        
        ref.child("users/customer/\(distributedCoupon.getUserUid())/waiting/\(distributedCoupon.getCouponKey())/alert").setValue(0)
        ref.child("stores/\(storeCode)/serving/\(distributedCoupon.getCouponKey())").removeValue()
        //!!!!!!!
        ref.child("users/customer/\(distributedCoupon.getUserUid())/waiting/\(distributedCoupon.getUserKey())").removeValue()
        
        refHandle = ref.child("stores/\(storeCode)/serving").observe( .value, with: { (snapshot) in
            print(snapshot.childrenCount)
            
            var i = 1
            for child in snapshot.children{
                let fchild = child as! DataSnapshot
                let key = fchild.key
                self.ref.child("stores/\(self.storeCode)/serving/\(key)/order").setValue(i)
                
                i += 1
                
            }
        })
        
        ref.child("stores/\(storeCode)/serving").removeObserver(withHandle: refHandle!)
        
        ref.child("users").child("owner").child(uid!).child("served").childByAutoId().setValue(["code": distributedCoupon.getCode(),
                                                                                                "dtime": distributedCoupon.getDtime(),
                                                                                                "couponKey": distributedCoupon.getCouponKey(),
                                                                                                "orderedMenu": distributedCoupon.getOrderedMenu(),
                                                                                                "numOfCoupon": distributedCoupon.getNumOfCoupon(),
                                                                                                "order": distributedCoupon.getOrder(),
                                                                                                "used": distributedCoupon.getUsed(),
                                                                                                "available": distributedCoupon.getAvailable(),
                                                                                                "userKey":distributedCoupon.getUserKey(),
                                                                                                "userUid":distributedCoupon.getUserUid(),
                                                                                                "displayName":distributedCoupon.getDisplayName()])
        
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func deleteOrderButtonAction(_ sender: Any) {
        if distributedCoupon.getUserUid() != "" {
            ref.child("users/customer/\(distributedCoupon.getUserUid())/waiting/\(distributedCoupon.getCouponKey())/alert").setValue(waitingOrder.ERROR_ORDER)
        }
        
        
        ref.child("stores/\(storeCode)/serving/\(distributedCoupon.getCouponKey())").removeValue()
        
        refHandle = ref.child("stores/\(storeCode)/serving").observe( .value, with: { (snapshot) in
            print(snapshot.childrenCount)
            
            var i = 1
            for child in snapshot.children{
                let fchild = child as! DataSnapshot
                let key = fchild.key
                self.ref.child("stores/\(self.storeCode)/serving/\(key)/order").setValue(i)
                
                i += 1
                
            }
        })
        
        ref.child("stores/\(storeCode)/serving").removeObserver(withHandle: refHandle!)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
