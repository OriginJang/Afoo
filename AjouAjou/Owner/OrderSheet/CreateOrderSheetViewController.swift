//
//  CreateOrderSheetViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 26..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CreateOrderSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var couponControllView: UIView!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var couponNumberLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var refreshView: UIView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!

    
    let colors = Colors()
    let informOwner = InformOwner()
    var wiilDistributeCouponNumber:Int?
    
    let ref: DatabaseReference = Database.database().reference()
    var userRef: DatabaseReference!
    var refHandle: DatabaseHandle?
    var listenerHandle: AuthStateDidChangeListenerHandle?
    
    var menuList = [[String:Int]]()
    var selectedMenuList = [[String:Int]]()
    var totalPrice:Int = 0
    var orderedMenu = [String:Int]()
    var resultString:String = ""
    var distributedCoupon:DistributedCoupon?
    
    var numOfCoupon:Int = 0
    
    var check:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //delegate
        tableView.delegate = self
        tableView.dataSource = self
        //delegate end
        
        //design
        view.backgroundColor = colors.colorPrimary
        let edgeInsets:CGFloat = 8
        let cornerRadius:CGFloat = 10
        let shadowRadius:CGFloat = 2
        let shadowOpacity:Float = 0.3
        let height:Int = 2
        
        couponControllView.backgroundColor = UIColor.white
        couponControllView.layer.cornerRadius = cornerRadius
        couponControllView.layer.shadowColor = UIColor.black.cgColor
        couponControllView.layer.shadowRadius = shadowRadius
        couponControllView.layer.shadowOpacity = shadowOpacity
        couponControllView.layer.shadowOffset = CGSize(width: 0, height: height)
        
        downButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        downButton.layer.cornerRadius = cornerRadius
        downButton.layer.shadowColor = UIColor.black.cgColor
        downButton.layer.shadowRadius = shadowRadius
        downButton.layer.shadowOpacity = shadowOpacity
        downButton.layer.shadowOffset = CGSize(width: 0, height: height)
        
        upButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        upButton.layer.cornerRadius = cornerRadius
        upButton.layer.shadowColor = UIColor.black.cgColor
        upButton.layer.shadowRadius = shadowRadius
        upButton.layer.shadowOpacity = shadowOpacity
        upButton.layer.shadowOffset = CGSize(width: 0, height: height)
        
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowRadius = shadowRadius
        containerView.layer.shadowOpacity = shadowOpacity
        containerView.layer.shadowOffset = CGSize(width: 0, height: height)
        
        
        tableView.layer.cornerRadius = cornerRadius
        
        
        refreshView.backgroundColor = UIColor.white
        refreshView.layer.cornerRadius = cornerRadius
        refreshView.layer.shadowColor = UIColor.black.cgColor
        refreshView.layer.shadowRadius = shadowRadius
        refreshView.layer.shadowOpacity = shadowOpacity
        refreshView.layer.shadowOffset = CGSize(width: 0, height: height)
        
        refreshButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        refreshButton.layer.cornerRadius = cornerRadius
        refreshButton.layer.shadowColor = UIColor.black.cgColor
        refreshButton.layer.shadowRadius = shadowRadius
        refreshButton.layer.shadowOpacity = shadowOpacity
        refreshButton.layer.shadowOffset = CGSize(width: 0, height: height)
        
        cancelButton.backgroundColor = colors.colorSecondary
        cancelButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        cancelButton.layer.cornerRadius = cornerRadius
        cancelButton.layer.shadowColor = UIColor.black.cgColor
        cancelButton.layer.shadowRadius = shadowRadius
        cancelButton.layer.shadowOpacity = shadowOpacity
        cancelButton.layer.shadowOffset = CGSize(width: 0, height: height)
        
        finishButton.backgroundColor = colors.colorSecondary
        finishButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        finishButton.layer.cornerRadius = cornerRadius
        finishButton.layer.shadowColor = UIColor.black.cgColor
        finishButton.layer.shadowRadius = shadowRadius
        finishButton.layer.shadowOpacity = shadowOpacity
        finishButton.layer.shadowOffset = CGSize(width: 0, height: height)
        finishButton.addTarget(self, action: #selector(finishButtonAction), for: .touchUpInside)
        //design end

        
        
    }

    @IBAction func upButtonAction(_ sender: Any) {
        wiilDistributeCouponNumber = Int(couponNumberLabel.text!)
        if wiilDistributeCouponNumber != nil{
            wiilDistributeCouponNumber! += 1
            couponNumberLabel.text = "\(wiilDistributeCouponNumber!)"
        }else{
            couponNumberLabel.text = "1"
            check = true
        }
    }
    
    @IBAction func downButtonAction(_ sender: Any) {
        wiilDistributeCouponNumber = Int(couponNumberLabel.text!)
        if (wiilDistributeCouponNumber != nil && wiilDistributeCouponNumber! > 0 ){
            wiilDistributeCouponNumber! -= 1
            couponNumberLabel.text = "\(wiilDistributeCouponNumber!)"
        }else{
            couponNumberLabel.text = "0"
            check = true
        }
    }
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        listenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                let userUid = user?.uid
                let userRef = (self.ref).child("users/owner/\(userUid!)/inform")
                userRef.observe(.value, with: { (snapshot) in
                    let userDict = snapshot.value as? [String : AnyObject] ?? [:]
                    self.informOwner.setValuesForKeys(userDict)
                    let temp = self.informOwner.getStoreMenu()
                    for (key, value) in temp{
                        self.menuList.append([key:value])
                    }
                    DispatchQueue.global(qos: .background).async {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
                self.tableView.reloadData()
            }else{
                print("경고: 잘못된 접근입니다. user is nil")
            }
        })
        
        
    }
    
    //tableView delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "메뉴목록"
        }
        return "선택한 메뉴"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return menuList.count
        }
        
        return selectedMenuList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuListCell") as! CreateOrderSheetTableViewCell
        if indexPath.section == 0{
            for  (key,value) in menuList[indexPath.row]{
                cell.foodLabel.text = key
                cell.priceLabel.text = "\(value)원"
            }
        } else{
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            for  (key,value) in selectedMenuList[indexPath.row]{
                cell.foodLabel.text = key
                cell.priceLabel.text = "\(value)개"
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRowIndex = indexPath.row
        for (key, value) in menuList[selectedRowIndex]{
            orderedMenuToCountedFood(orderedMenu: [key:value])
            countedFoodToSelectedMenuList()
            print("orderedMenu :\(self.orderedMenu)")
        }
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0{
            return false
        }
        return true
    }
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        print(action)
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        self.orderedMenu.removeValue(forKey: [String](selectedMenuList[indexPath.row].keys)[0])
        self.selectedMenuList.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        print("canFocusRowAt")
        if indexPath.section == 1{
            return false
        }
        return true
    }

    //tableView delegate end

    
    func orderedMenuToCountedFood(orderedMenu: [String:Int]){
        for (food, price) in orderedMenu {
            if self.orderedMenu[food] != nil{
                self.orderedMenu[food]! += 1
                self.totalPrice += price
                totalPriceLabel.text = "\(totalPrice) 원"
            }else{
                self.orderedMenu[food] = 1
                self.totalPrice += price
                totalPriceLabel.text = "\(totalPrice) 원"
            }
        }
    }
    
    func countedFoodToSelectedMenuList()  {
        selectedMenuList.removeAll()
        for (key, value) in self.orderedMenu{
            self.selectedMenuList.append( [key:value] )
        }
        print("selectedMenuList: \(self.selectedMenuList)")
    }
    @IBAction func refreshButtonAction(_ sender: Any) {
        totalPrice = 0
        totalPriceLabel.text = "\(totalPrice) 원"
        selectedMenuList.removeAll()
        orderedMenu.removeAll()
        tableView.reloadData()
    }
//    @IBAction func finishButtonAction(_ sender: Any) {
//        let now = NSDate()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let stringDate = dateFormatter.string(from: now as Date)
//        if check{
//            self.numOfCoupon = Int(couponNumberLabel.text!)!
//        }
//        if !orderedMenu.isEmpty{
//            distributedCoupon = DistributedCoupon(code: informOwner.getStoreCode(),
//                                                  dtime: stringDate,
//                                                  orderedMenu: orderedMenu,
//                                                  numOfCoupon: numOfCoupon,
//                                                  order: 0,
//                                                  used: 0,
//                                                  available: 0)
//        }else{
//            let alert = UIAlertController(title: "알림", message: "메뉴를 입력해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
//
//            self.present(alert, animated: true, completion: nil)
//
//        }
//
//
//    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let receiptVC = segue.destination as? ReceiptViewController else { return }
//        distributedCoupon?.setCouponKey(couponKey: self.ref.childByAutoId().key)
//
//        receiptVC.distributedCoupon = distributedCoupon!
//        receiptVC.totalPrice = self.totalPrice
//        receiptVC.storeName = informOwner.getStoreName()
//        receiptVC.storeCode = informOwner.getStoreCode()
//        receiptVC.requiredCoupon = informOwner.getRequiredCoupon()
//        receiptVC.orderedMenu = self.orderedMenu
//    }
    
    @objc func finishButtonAction() {
        if !orderedMenu.isEmpty{
            let now = NSDate()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
            let stringDate = dateFormatter.string(from: now as Date)
            if check{
                self.numOfCoupon = Int(couponNumberLabel.text!)!
            }
        
            var uuid = UUID().uuidString
            print(uuid)
            let range = uuid.index(uuid.endIndex, offsetBy: -13)..<uuid.endIndex
            uuid.removeSubrange(range)
            let code = uuid.components(separatedBy: ["-"]).joined()
            
            distributedCoupon = DistributedCoupon(code: code,
                                                  dtime: stringDate,
                                                  orderedMenu: orderedMenu,
                                                  numOfCoupon: numOfCoupon,
                                                  order: 0,
                                                  used: 0,
                                                  available: 0,
                                                  displayName:"")
            
            let receiptVC = self.storyboard?.instantiateViewController(withIdentifier: "ReceiptViewController") as! ReceiptViewController
            distributedCoupon?.setCouponKey(couponKey: self.ref.childByAutoId().key)
            
            receiptVC.distributedCoupon = distributedCoupon!
            receiptVC.totalPrice = self.totalPrice
            receiptVC.storeName = informOwner.getStoreName()
            receiptVC.storeCode = informOwner.getStoreCode()
            receiptVC.requiredCoupon = informOwner.getRequiredCoupon()
            receiptVC.orderedMenu = self.orderedMenu
            
            
            
            self.present(receiptVC, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "알림", message: "메뉴를 입력해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        Auth.auth().removeStateDidChangeListener(listenerHandle!)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
