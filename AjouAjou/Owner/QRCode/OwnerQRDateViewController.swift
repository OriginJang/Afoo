//
//  OwnerQRDateViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 7..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase

class OwnerQRDateViewController: UIViewController {

    let ref = Database.database().reference()
    var usedCoupon:UsedCoupon=UsedCoupon()
    var storeCode:String = ""
    var order:Int = 0
    let distributedCoupon : DistributedCoupon = DistributedCoupon()
    let waitingOrder:WaitingOrder = WaitingOrder()
    var storeName:String = ""
    var requiredCoupon:Int = 0
    
    let uid = Auth.auth().currentUser?.uid
    
    var couponKey:String = Database.database().reference().childByAutoId().key
    
    let colors = Colors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("passed requiredCoupon: \(requiredCoupon)")
        view.backgroundColor = colors.colorPrimary
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        createCountedOrderServing()
        
        ref.child("stores/\(storeCode)/inform/storeName").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                let storeName = snapshot.value as? String
                self.storeName = storeName!
                
                self.ref.child("stores/\(self.storeCode)/serving/\(self.couponKey)").observe( .value) { (snapshot) in
                    if snapshot.exists(){
                        let waitingRef:DatabaseReference = self.ref.child("users").child("customer").child(self.usedCoupon.userUid).child("waiting").child(self.couponKey)
                        
                        let dcDict = snapshot.value as? [String : AnyObject] ?? [:]
                        self.distributedCoupon.setValuesForKeys(dcDict)
                        self.waitingOrder.setStoreName(storeName: self.storeName)
                        self.waitingOrder.setDtime(dtime: self.distributedCoupon.getDtime())
                        self.waitingOrder.setStoreCode(storeCode: self.storeCode)
                        self.waitingOrder.setOrder(order: self.order)
                        self.waitingOrder.setAlert(alert: self.waitingOrder.BEFORE_GENERAL_ORDER_NOTIFICATION)
                        waitingRef.setValue(["storeName":self.waitingOrder.getStoreName(),
                                             "storeCode":self.waitingOrder.getStoreCode(),
                                             "dtime":self.waitingOrder.getDtime(),
                                             "order":self.waitingOrder.getOrder(),
                                             "alert":self.waitingOrder.getAlert(),
                                             "numOfCoupon":0,
                                             "requiredCoupon":self.requiredCoupon])
                        self.ref.child("users/owner/\(self.uid!)/usedCoupon").childByAutoId().setValue(["dtime":self.usedCoupon.getDtime(),
                                                                                                        "userUid":self.usedCoupon.getUserUid()])
                        
                        self.ref.child("users/customer/\(self.usedCoupon.getUserUid())/storage/\(self.waitingOrder.storeCode)/usage").observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.exists(){
                                print(snapshot)
                                let usage = snapshot.value as? Int
                                print(usage)
                                if usage != nil{
                                    self.ref.child("users/customer/\(self.usedCoupon.getUserUid())/storage/\(self.waitingOrder.storeCode)/numOfCoupon").observeSingleEvent(of: .value, with: { (snapshot) in
                                        let numOfCoupon = snapshot.value as? Int
                                        if numOfCoupon! >= self.requiredCoupon {
                                            let updateNumOfCoupon = numOfCoupon! - self.requiredCoupon
                                            self.ref.child("users/customer/\(self.usedCoupon.getUserUid())/storage/\(self.waitingOrder.storeCode)/numOfCoupon").setValue(updateNumOfCoupon)
                                        }
                                        
                                    })
                                    let updateUsage = usage! + 1
                                    self.ref.child("users/customer/\(self.usedCoupon.getUserUid())/storage/\(self.waitingOrder.storeCode)/usage").setValue(updateUsage)
                                    
                                    
                                }else{
                                    let alert = UIAlertController(title: "알림", message: "데이터베이스 오류입니다.", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:{ (action) in
                                        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }
                            }else{
                                let alert = UIAlertController(title: "알림", message: "올바르지 않은 QR코드 입니다.1", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:{ (action) in
                                    self.presentingViewController?.presentingViewController?.dismiss(animated: true)
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        })
                    }
                    
                }
            }else{
                let alert = UIAlertController(title: "알림", message: "올바르지 않은 QR코드입니다.2", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:{ (action) in
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }

    }
    
    func createCountedOrderServing() {
        let userRef = (self.ref).child("stores/\(self.storeCode)/serving")
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChildren() {
                print(snapshot.childrenCount)
                self.order = Int(snapshot.childrenCount + 1)
                self.createServing()
            }else{
                self.order = 1
                self.createServing()
            }
        }
    }
    func createServing() {
        
        var uuid = UUID().uuidString
        print(uuid)
        let range = uuid.index(uuid.endIndex, offsetBy: -13)..<uuid.endIndex
        uuid.removeSubrange(range)
        let code = uuid.components(separatedBy: ["-"]).joined()
        
        distributedCoupon.setCode(code: code)
        
        let userRef = (self.ref).child("stores/\(storeCode)")
        
        userRef.child("serving").child(couponKey).setValue(["code":storeCode,
                                                                 "dtime":usedCoupon.getDtime(),
                                                                 "orderedMenu":["쿠폰 메뉴":1],
                                                                 "numOfCoupon":0,
                                                                 "order":self.order,
                                                                 "used":self.distributedCoupon.getUsed(),
                                                                 "available": 0,
                                                                 "couponKey": couponKey,
                                                                 "displayName":""])
        
    }
    @IBAction func checkButtonAction(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
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
