//
//  CustomerMainViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 17..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import GoogleSignIn

class CustomerMainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let colors = Colors()
    @IBOutlet weak var topView: UIView!
    
    
    @IBOutlet weak var customerSideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var customerSideMenuView: UIView!
    
    @IBOutlet weak var logoMainImageView: UIImageView!
    
    @IBOutlet weak var otherPlaceButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var informationButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var reservationButton: UIButton!
    @IBOutlet weak var acceptCouponButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let ref: DatabaseReference = Database.database().reference()
    var userRef: DatabaseReference!
    var servingListenerHandle: DatabaseHandle?
    var waitingListenerHandle: DatabaseHandle?
    var uid:String?
    
    var reloadTable: DispatchWorkItem!
    
    var userListenerHandle: AuthStateDidChangeListenerHandle?
    
    let informCustomer: InformCustomer = InformCustomer()
    
    var storeCodeList = [[String:String]]()
    var waitingOrderList = [[WaitingOrder]]()
    var listenerList = [DatabaseHandle]()
    
    var key:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView delegate
        tableView.delegate = self
        tableView.dataSource = self
        //tableView delegate end
        
        let edgeInsets:CGFloat = 8
        let ButtonWidth:CGFloat = 224
        let ButtonHeight:CGFloat = 40
        let rightEdgeInsets:CGFloat =  ButtonWidth - (ButtonHeight - edgeInsets)
        settingButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: rightEdgeInsets)
        logoutButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets+3, bottom: edgeInsets, right: rightEdgeInsets)
        informationButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: rightEdgeInsets)
        notificationButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: rightEdgeInsets)
        eventButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: rightEdgeInsets)
        otherPlaceButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: rightEdgeInsets)
        
        view.backgroundColor = colors.colorPrimary
        
        topView.backgroundColor = colors.colorPrimary
        
        logoMainImageView.image = UIImage(named: "afoo_logo_white.png")
        
        reservationButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        reservationButton.layer.cornerRadius = 25
        reservationButton.layer.shadowOpacity = 0.3
        reservationButton.layer.shadowColor = UIColor.black.cgColor
        reservationButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        acceptCouponButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        acceptCouponButton.layer.cornerRadius = 25
        acceptCouponButton.layer.shadowOpacity = 0.3
        acceptCouponButton.layer.shadowColor = UIColor.black.cgColor
        acceptCouponButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        // Do any additional setup after loading the view.
        
        //side menu
        customerSideMenuView.layer.shadowColor = UIColor.black.cgColor
        customerSideMenuView.layer.shadowOpacity = 0.3
        customerSideMenuView.layer.shadowOffset = CGSize(width: 1, height: 0)
        
        customerSideMenuConstraint.constant = -250
        
        uid = Auth.auth().currentUser?.uid
        if uid != nil{
            let userName = Auth.auth().currentUser?.displayName
            let userEmail = Auth.auth().currentUser?.email

            userNameLabel.text = userName
            userEmailLabel.text = userEmail
        }
        
        userListenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                let userUid = user?.uid
                let userRef = (self.ref).child("users/customer/\(userUid!)/inform")
                
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChildren(){
                        let userDict = snapshot.value as? [String : AnyObject] ?? [:]
                        self.informCustomer.setValuesForKeys(userDict)
                    }else{
                        self.performSegue(withIdentifier: "CustomerFirstLoginSegue", sender: self)
                    }
                })
            }else{
                
                print("경고: 잘못된 접근입니다. user is nil")
            }
        })
        
        otherPlaceButton.addTarget(self, action: #selector(goToDevelopmentVC), for: .touchUpInside)
        notificationButton.addTarget(self, action: #selector(goToNoticeVC), for: .touchUpInside)
        eventButton.addTarget(self, action: #selector(goToDevelopmentVC), for: .touchUpInside)
        informationButton.addTarget(self, action: #selector(goToDeveloperVC), for: .touchUpInside)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        ref.child("users/customer/\(uid!)/waiting").observeSingleEvent(of: .value) { (snapshot) in
            self.waitingOrderList.removeAll()
            self.storeCodeList.removeAll()
            for child in snapshot.children{
                let waitingOrder: WaitingOrder = WaitingOrder()
                let fcild = child as! DataSnapshot
                let waitingOrderDict = fcild.value as? [String : AnyObject] ?? [:]
                let key = fcild.key
                
                waitingOrder.setValuesForKeys(waitingOrderDict)
                self.waitingOrderList.append([waitingOrder])
                self.storeCodeList.append([waitingOrder.getStoreCode():key])
            }

            for storeCodeAndKey in self.storeCodeList{
                for (storeCode, couponKey) in storeCodeAndKey{
                    self.servingListenerHandle = self.ref.child("stores/\(storeCode)/serving/\(couponKey)/order").observe(.value, with: { (snapshot) in

                        if snapshot.exists() {
                            let changedOrder = snapshot.value as! Int
                            self.ref.child("users/customer/\(self.uid!)/waiting/\(couponKey)/order").setValue(changedOrder)
                        }else{
//                            self.ref.child("users/customer/\(self.uid!)/waiting/\(couponKey)/")
//                            self.performSegue(withIdentifier: "OrderCompleteSegue", sender: nil)
                            self.ref.child("users/customer/\(self.uid!)/waiting/\(couponKey)").removeValue()
                        }
                        
                        DispatchQueue.global(qos: .background).async {
                            DispatchQueue.main.async {
                                self.reloadTable = DispatchWorkItem(block: {
                                    self.tableView.reloadData()
                                })
                                
                            }
                        }
                        
                    })
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
        ref.child("users/customer/\(uid!)/waiting").observe( DataEventType.childRemoved) { (snapshot) in
            
            let temp: WaitingOrder = WaitingOrder()
            
            let tempDict = snapshot.value as? [String : AnyObject] ?? [:]
            temp.setValuesForKeys(tempDict)
            print("!!!!!!! \(temp.getAlert())")
            if (temp.getAlert() == 0){
                self.performSegue(withIdentifier: "OrderCompleteSegue", sender: nil)
            }else if(temp.getAlert() == -3){
                let alert = UIAlertController(title: "주의", message: "주문한 음식 목록이 삭제되었습니다. 점주에게 문의하세요.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }
        
        waitingListenerHandle = ref.child("users/customer/\(uid!)/waiting").observe( .value) { (snapshot) in
            self.waitingOrderList.removeAll()
            self.storeCodeList.removeAll()
            for child in snapshot.children{
                let waitingOrder: WaitingOrder = WaitingOrder()
                let fcild = child as! DataSnapshot
                let waitingOrderDict = fcild.value as? [String : AnyObject] ?? [:]
                let key = fcild.key
                
                waitingOrder.setValuesForKeys(waitingOrderDict)
                self.waitingOrderList.append([waitingOrder])
                self.storeCodeList.append([waitingOrder.getStoreCode():key])
                
            }
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waitingOrderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "waitingCell") as! CustomerMainTableViewCell
        if !waitingOrderList.isEmpty {
            if indexPath.row == waitingOrderList.count{
                self.tableView.reloadData()
            }
            let waitingOrder = waitingOrderList[indexPath.row]
            cell.storeNameLabel.text = waitingOrder[0].getStoreName()
            cell.dtimeLabel.text = waitingOrder[0].getDtime()
            cell.waitingLabel.text = "대기번호 \(waitingOrder[0].getOrder())번 입니다."
        }
        

        return cell
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance().disconnect()
        } catch  {
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func panPerform(_ sender: UIPanGestureRecognizer) {
        
        if (sender.state == .began || sender.state == .changed) {
            
            let translation = sender.translation(in: self.view).x
            let velocity = sender.velocity(in: self.view).x
            print(velocity)
            if translation > 0 {
                if velocity > 1000{
                    if customerSideMenuConstraint.constant < 0 {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.customerSideMenuConstraint.constant = 0
                            self.shadowView.isHidden = false
                            self.view.layoutIfNeeded()
                        })
                    }
                }
                if velocity > 1{
                    if customerSideMenuConstraint.constant < 0 {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.customerSideMenuConstraint.constant += translation / 20
                            self.view.layoutIfNeeded()
                        })
                    }
                }
                
            }else if translation == 0 {
                
            }
            else{
                if velocity < -1000{
                    if customerSideMenuConstraint.constant > -240 {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.customerSideMenuConstraint.constant = -240
                            self.shadowView.isHidden = true
                            self.view.layoutIfNeeded()
                        })
                    }
                }
                if customerSideMenuConstraint.constant > -240 {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.customerSideMenuConstraint.constant += translation / 20
                        self.view.layoutIfNeeded()
                    })
                }
            }
            
        }else if sender.state == .ended{
            
            if customerSideMenuConstraint.constant < -120{
                UIView.animate(withDuration: 0.2, animations: {
                    self.customerSideMenuConstraint.constant = -240
                    self.shadowView.isHidden = true
                    self.view.layoutIfNeeded()
                })
            }else{
                UIView.animate(withDuration: 0.2, animations: {
                    self.customerSideMenuConstraint.constant = 0
                    self.shadowView.isHidden = false
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    @IBAction func removeSideMenuBtn(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.customerSideMenuConstraint.constant = -240
            self.shadowView.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "customerToQRReader"{
            (segue.destination as! QRReaderViewController).check = "CUSTOMER"
        }else if segue.identifier == "customerModifyInformSegue"{
            guard let modificationVC = segue.destination as? UpdateInformCustomerViewController else { return }
            modificationVC.isFirst = false
        }
    }
    
    @IBAction func sideMenuButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.customerSideMenuConstraint.constant = 0
            self.shadowView.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func goToDevelopmentVC() {
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "DevelopmentViewController") as! DevelopmentViewController
        self.present(nextView, animated: true, completion: nil)
    }
    
    @objc func goToNoticeVC() {
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.present(nextView, animated: true, completion: nil)
    }
    
    
    @objc func goToDeveloperVC() {
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "DeveloperViewController") as! DeveloperViewController
        self.present(nextView, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        Auth.auth().removeStateDidChangeListener(userListenerHandle!)
        ref.removeAllObservers()
        reloadTable?.cancel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
