//
//  OwnerMainViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 15..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SnapKit


class OwnerMainViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var otherPlaceButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var informationButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
    @IBOutlet weak var shadowView: UIView!
    

    
    @IBOutlet weak var issueCouponButton: UIButton!
    @IBOutlet weak var acceptCouponButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    let informOwner: InformOwner = InformOwner()
    
    let ref: DatabaseReference = Database.database().reference()
    var userRef: DatabaseReference!
    var refHandle: DatabaseHandle?
    
    var AuthStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    let fontResource = FontResource()
    let color = Colors()
    
    let distributedCoupon: DistributedCoupon = DistributedCoupon()
    var dcList = [[DistributedCoupon]]()
    
    var servingList = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view design
        //status bar
//        let statusBar = UIView()
//        self.view.addSubview(statusBar)
//        statusBar.backgroundColor = color.colorPrimary
//        statusBar.snp.makeConstraints({ (m) in
//            m.right.top.left.equalTo(self.view)
//            m.height.equalTo(20)
//        })
        //status bar end
        
        //tableView delegate
        tableView.delegate = self
        tableView.dataSource = self
        //tableView delegate end
        
        sideMenuView.layer.shadowColor = UIColor.black.cgColor
        sideMenuView.layer.shadowOpacity = 0.3
        sideMenuView.layer.shadowOffset = CGSize(width: 1, height: 0)
        
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
        sideMenuConstraint.constant = -240
        
        view.backgroundColor = color.colorPrimary
        
        
        issueCouponButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        issueCouponButton.layer.cornerRadius = 25
        issueCouponButton.layer.shadowOpacity = 0.5
        issueCouponButton.layer.shadowColor = UIColor.black.cgColor
        issueCouponButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        acceptCouponButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        acceptCouponButton.layer.cornerRadius = 25
        acceptCouponButton.layer.shadowOpacity = 0.5
        acceptCouponButton.layer.shadowColor = UIColor.black.cgColor
        acceptCouponButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        otherPlaceButton.addTarget(self, action: #selector(goToDevelopmentVC), for: .touchUpInside)
        notificationButton.addTarget(self, action: #selector(goToNoticeVC), for: .touchUpInside)
        eventButton.addTarget(self, action: #selector(goToDevelopmentVC), for: .touchUpInside)
        informationButton.addTarget(self, action: #selector(goToDeveloperVC), for: .touchUpInside)
        //view design end
    
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        //informOwner
        AuthStateListenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                let userUid = user?.uid
                let userRef = (self.ref).child("users/owner/\(userUid!)/inform")
                
                userRef.observe(.value, with: { (snapshot) in
                    let userDict = snapshot.value as? [String : AnyObject] ?? [:]
                    self.informOwner.setValuesForKeys(userDict)
                    let storeName = self.informOwner.getStoreName()
                    let accountNum = self.informOwner.getAccountNum()
                    self.storeNameLabel.text = storeName
                    self.accountLabel.text = accountNum
                    
                    if (storeName == "" || accountNum == "") {
                        self.performSegue(withIdentifier: "OwnerFirstLoginSegue", sender: self)
                    }
                    
                    //distributedCoupon
                    self.ref.child("stores/\(self.informOwner.storeCode)/serving").observe(DataEventType.value) { (snapshot) in
                        self.dcList.removeAll()
                        for child in snapshot.children{
                            let fchild = child as! DataSnapshot
                            let distributedCouponDict = fchild.value as? [String : AnyObject] ?? [:]
                            let dc = DistributedCoupon()
                            print(distributedCouponDict)
                            dc.setValuesForKeys(distributedCouponDict)
                            self.dcList.append([dc])
                        }
                        DispatchQueue.global(qos: .background).async {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                })
            }else{
                
                print("경고: 잘못된 접근입니다. user is nil")
            }
        })
        //informOwner end
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

    }
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(AuthStateListenerHandle!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dcList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "servingCell") as! OwnerMainTableViewCell
        cell.orderMenuLabel.numberOfLines = 0
        
        for dc in dcList[indexPath.row]{
            print(dc.getUsed())

            if dc.getUsed() != 0{
                cell.starImageView.image = UIImage(named: "userStar.png")
            }else{
                cell.starImageView.image = UIImage(named: "star.png")
            }
            var temp = dc.getDtime()
            if temp != ""{
                let range = temp.startIndex..<temp.index(temp.startIndex, offsetBy: 14)
                temp.removeSubrange(range)
            }
            
            
            
            if dc.getDisplayName() != ""{
                cell.orderNumberLabel.text = "주문자: \(dc.getDisplayName())"
            }else{
                let orderNumber = temp.components(separatedBy: ["-",":"," "]).joined()
                cell.orderNumberLabel.text = "주문번호: \(orderNumber)"
            }
            
            
            let orderMenu = self.orderedMuneToString(orderedMenu: dc.getOrderedMenu())
            cell.orderMenuLabel.text = orderMenu
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "detailSegue",sender: self)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        let dc = dcList[indexPath.row]
        self.dcList.remove(at: indexPath.row)
        ref.child("stores/\(informOwner.getStoreCode())/serving/\(dc[0].getCouponKey())").removeValue()
        
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
        refHandle = ref.child("stores/\(self.informOwner.getStoreCode())/serving").observe( .value, with: { (snapshot) in
            var i = 1
            for child in snapshot.children{
                let fchild = child as! DataSnapshot
                let key = fchild.key
                self.ref.child("stores/\(self.informOwner.getStoreCode())/serving/\(key)/order").setValue(i)
                
               i += 1
                
            }
        })
        
        ref.child("stores/\(self.informOwner.getStoreCode())/serving").removeObserver(withHandle: refHandle!)
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue")
        if segue.identifier == "detailSegue"{
            guard let detailVC = segue.destination as? OwnerMainDetailViewController else { return }
            detailVC.storeCode = informOwner.storeCode
            
            detailVC.dtime = self.distributedCoupon.getDtime()
            detailVC.couponKey = self.distributedCoupon.getCouponKey()
            
            
            for dc in self.dcList[tableView.indexPathForSelectedRow!.row]{
                detailVC.distributedCoupon = dc
            }
        } else if segue.identifier == "ownerToQRReader"{
            guard let QrVC = segue.destination as? QRReaderViewController else { return }
            QrVC.check = "OWNER"
        } else if segue.identifier == "ownerModifyInformSegue"{
            guard let modificationVC = segue.destination as? UpdateInformOwnerViewController else { return }
            modificationVC.isFirst = false
        }
        
    
    }
    
    
    @IBAction func buttonAction(_ sender: Any) {

    }
    
    
    @IBAction func panPerformed(_ sender: UIPanGestureRecognizer) {
        
        if (sender.state == .began || sender.state == .changed) {
            
            let translation = sender.translation(in: self.view).x
            let velocity = sender.velocity(in: self.view).x
            print(velocity)
            if translation > 0 {
                if velocity > 1000{
                    if sideMenuConstraint.constant < 0 {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.sideMenuConstraint.constant = 0
                            self.shadowView.isHidden = false
                            self.view.layoutIfNeeded()
                        })
                    }
                }
                if velocity > 1{
                    if sideMenuConstraint.constant < 0 {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.sideMenuConstraint.constant += translation / 20
                            self.view.layoutIfNeeded()
                        })
                    }
                }
                
            }else if translation == 0 {
                
            }
            else{
                if velocity < -1000{
                    if sideMenuConstraint.constant > -240 {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.sideMenuConstraint.constant = -240
                            self.shadowView.isHidden = true
                            self.view.layoutIfNeeded()
                        })
                    }
                }
                if sideMenuConstraint.constant > -240 {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.sideMenuConstraint.constant += translation / 20
                        self.view.layoutIfNeeded()
                    })
                }
            }
            
        }else if sender.state == .ended{
            
            if sideMenuConstraint.constant < -120{
                UIView.animate(withDuration: 0.2, animations: {
                    self.sideMenuConstraint.constant = -240
                    self.shadowView.isHidden = true
                    self.view.layoutIfNeeded()
                })
            }else{
                UIView.animate(withDuration: 0.2, animations: {
                    self.sideMenuConstraint.constant = 0
                    self.shadowView.isHidden = false
                    self.view.layoutIfNeeded()
                })
            }
        }
            
        
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
    
    @IBAction func removeSideMenuBtn(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.sideMenuConstraint.constant = -240
            self.shadowView.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func LogoutButtonAction(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sideMenuButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.sideMenuConstraint.constant = 0
            self.shadowView.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
