//
//  CustomerQRDataViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 1..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class CustomerQRDataViewController: UIViewController {

    let ref: DatabaseReference = Database.database().reference()
    var userRef: DatabaseReference!
    var refHandle: DatabaseHandle?
    var listenerHandle: DatabaseHandle?
    var listenerHandleSecond: DatabaseHandle?
    let uid = Auth.auth().currentUser?.uid
    
    let distributedCoupon : DistributedCoupon = DistributedCoupon()
    var coupon: Coupon = Coupon()
    var waitingOrder:WaitingOrder = WaitingOrder()
    var couponKey:String?
    
    let colors = Colors()
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.colorPrimary
        self.hideAllViewContents()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        //storeName
        ref.child("stores/\(coupon.getStoreCode())/inform/storeName").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let storeName = snapshot.value as? String
                self.coupon.setStoreName(storeName: storeName!)
            }else{

                let alert = UIAlertController(title: "알림", message: "올바른 QR코드가 아닙니다.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:{ (action) in
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        ref.child("stores/\(coupon.getStoreCode())/serving/\(couponKey!)/available").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                let available = snapshot.value as! Int
                if available == 1{
                    self.ref.child("users/customer/\(self.uid!)/storage/\(self.coupon.getStoreCode())").observeSingleEvent(of: .value, with: { (snapshot) in
                        if !snapshot.hasChildren() {
                            //초기 발급
                            self.ref.child("users").child("customer").child("\(self.uid!)").child("storage").child("\(self.coupon.getStoreCode())").setValue(["numOfCoupon":self.coupon.getNumOfCoupon(),
                                                                                                                                                              "requiredCoupon":self.coupon.getRequiredCoupon(),
                                                                                                                                                              "storeCode":self.coupon.getStoreCode(),
                                                                                                                                                              "storeName":self.coupon.getStoreName(),
                                                                                                                                                              "usage":self.coupon.getUsage()])
                            self.showAllViewContents()
                        }else{
                            //쿠폰등록
                            self.ref.child("users/customer/\(self.uid!)/storage/\(self.coupon.getStoreCode())/numOfCoupon").observeSingleEvent(of: .value, with: { (snapshot) in
                                let storageCoupon = snapshot.value as! Int
                                let numOfCoupon = storageCoupon + self.coupon.getNumOfCoupon()
                                self.ref.child("users/customer/\(self.uid!)/storage/\(self.coupon.getStoreCode())/numOfCoupon").setValue(numOfCoupon)
                                self.showAllViewContents()
                                
                            })
                        }
                    })
                }else{
                    let alert = UIAlertController(title: "주의", message: "사용할 수 없는 쿠폰입니다.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:{ (action) in
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                
                self.hideAllViewContents()
            }
            
        }
        
        //waiting
        ref.child("stores/\(coupon.getStoreCode())/serving/\(couponKey!)").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                let waitingRef:DatabaseReference = self.ref.child("users").child("customer").child(self.uid!).child("waiting").child(self.couponKey!)
                
                let dcDict = snapshot.value as? [String : AnyObject] ?? [:]
                self.distributedCoupon.setValuesForKeys(dcDict)
                self.waitingOrder.setStoreName(storeName: self.coupon.getStoreName())
                self.waitingOrder.setDtime(dtime: self.distributedCoupon.getDtime())
                self.waitingOrder.setStoreCode(storeCode: self.coupon.getStoreCode())
                self.waitingOrder.setOrder(order: self.distributedCoupon.getOrder())
                self.waitingOrder.setAlert(alert: self.waitingOrder.BEFORE_GENERAL_ORDER_NOTIFICATION)
                //            let dtime = self.distributedCoupon.getDtime()
                //            let order = self.distributedCoupon.getOrder()
                waitingRef.setValue(["storeName":self.waitingOrder.getStoreName(),
                                     "storeCode":self.waitingOrder.getStoreCode(),
                                     "dtime":self.waitingOrder.getDtime(),
                                     "order":self.waitingOrder.getOrder(),
                                     "alert":self.waitingOrder.getAlert()])
            }
            
        }
        
        //avaialbe,used
        ref.child("stores/\(coupon.getStoreCode())/serving/\(couponKey!)/available").observeSingleEvent(of: .value) { (snapshot) in
            let available = snapshot.value as? Int
            if available == 1{
                self.ref.child("stores/\(self.coupon.getStoreCode())/serving/\(self.couponKey!)/available").setValue(0)
                self.ref.child("stores/\(self.coupon.getStoreCode())/serving/\(self.couponKey!)/used").setValue(1)
                self.ref.child("stores/\(self.coupon.getStoreCode())/serving/\(self.couponKey!)").updateChildValues(["userKey":self.ref.childByAutoId().key, "userUid":self.uid!])
            }
        }
        
        

    }
    
    func hideAllViewContents() {
        self.imageView.isHidden = true
        self.label1.isHidden = true
        self.label2.isHidden = true
        self.checkButton.isHidden = true
    }
    func showAllViewContents() {
        self.imageView.isHidden = false
        self.label1.isHidden = false
        self.label2.isHidden = false
        self.checkButton.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
    }

    @IBAction func checkButtonAction(_ sender: Any) {
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
