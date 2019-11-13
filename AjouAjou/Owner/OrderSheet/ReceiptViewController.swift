
//
//  ReceiptViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 28..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ReceiptViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var dtimeLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var numOfCouponLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var codeView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let ref: DatabaseReference = Database.database().reference()
    var refHandle: DatabaseHandle?
    var listenerHandle: AuthStateDidChangeListenerHandle?
    let userUid = Auth.auth().currentUser?.uid
    var couponKey:String = ""
    
    var distributedCoupon = DistributedCoupon()
    var storeName:String?
    var totalPrice:Int?
    var storeCode:String?
    var requiredCoupon:Int?
    
    var orderedMenu = [String:Int]()
    var orderedMenuForCell = [[String:Int]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //delegate
        tableView.delegate = self
        tableView.dataSource = self
        //delegate end
        
        let dtime = distributedCoupon.getDtime()
        self.couponKey = self.distributedCoupon.getCouponKey()
        var temp = distributedCoupon.getDtime()
        let range = temp.startIndex..<temp.index(temp.startIndex, offsetBy: 14)
        temp.removeSubrange(range)
        let orderNumber = temp.components(separatedBy: [".",":"," "]).joined()
        
        dtimeLabel.text = dtime
        storeNameLabel.text = storeName!
        orderNumberLabel.text = orderNumber
        numOfCouponLabel.text = String(distributedCoupon.getNumOfCoupon())
        totalPriceLabel.text = String(totalPrice!)
        
        for (key, value) in orderedMenu{
            orderedMenuForCell.append([key:value])
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        createCountedOrderServing()
        var filter: CIFilter!
//        key:code:storeCode:numOfCoupon:requiredCoupon
        let qrCodeMsg = "\(self.couponKey):\(distributedCoupon.getCode()):\(storeCode!):\(distributedCoupon.getNumOfCoupon()):\(requiredCoupon!)"
        let data = qrCodeMsg.data(using: .ascii, allowLossyConversion: false)
        
        print(qrCodeMsg)
        let transform = CGAffineTransform(scaleX: 100, y: 100)
        
        filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        let fImage = UIImage(ciImage: (filter.outputImage?.transformed(by: transform))!)
        codeView.image = fImage
        ref.child("stores/\(self.storeCode!)/serving/\(self.distributedCoupon.getCouponKey())/used").observe(.value) { (snapshot) in
            print(snapshot)

            let used = snapshot.value as? Int
            if used == 1{
                self.presentingViewController?.presentingViewController?.dismiss(animated: true)
            }
        }
        
    }
    
    func createCountedOrderServing() {
        let userRef = (self.ref).child("stores/\(self.storeCode!)/serving")
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChildren() {
                print(snapshot.childrenCount)
                self.distributedCoupon.order = Int(snapshot.childrenCount + 1)
                self.createServing()
            }else{
                self.distributedCoupon.order = 1
                self.createServing()
            }
            
        }
    }
    func createServing() {
        
//        var uuid = UUID().uuidString
//        print(uuid)
//        let range = uuid.index(uuid.endIndex, offsetBy: -13)..<uuid.endIndex
//        uuid.removeSubrange(range)
//        let code = uuid.components(separatedBy: ["-"]).joined()
//
//        distributedCoupon.setCode(code: code)
        
        let userRef = (self.ref).child("stores/\(storeCode!)")
        
        userRef.child("serving").child(self.couponKey).setValue(["code":self.distributedCoupon.getCode(),
                                                           "dtime":self.distributedCoupon.getDtime(),
                                                           "orderedMenu":self.distributedCoupon.getOrderedMenu(),
                                                           "numOfCoupon":self.distributedCoupon.getNumOfCoupon(),
                                                           "order":self.distributedCoupon.getOrder(),
                                                           "used":self.distributedCoupon.getUsed(),
                                                           "available": 1,
                                                           "couponKey": self.couponKey,
                                                           "displayName":self.distributedCoupon.getDisplayName()])
        print("createServing")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        disavailable()
    }
    func disavailable() {
        let userRef = (self.ref).child("stores/\(self.storeCode!)")
        userRef.child("serving/\(self.couponKey)/available").setValue(0)
        print("disavailable")
    }
    
    //tableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedMenuForCell.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiptCell") as! ReceiptTableViewCell
        for (key, value) in orderedMenuForCell[indexPath.row]{
            cell.foodLabel.text = key
            cell.numberLabel.text = "\(value) 개"
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    //tableView delegate end
    
    @IBAction func checkButton(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
