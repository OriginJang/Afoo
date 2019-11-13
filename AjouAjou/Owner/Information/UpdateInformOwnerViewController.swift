//
//  UpdateInformOwnerViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 20..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class UpdateInformOwnerViewController: UIViewController,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource,BEMCheckBoxDelegate {
    
    
    @IBOutlet weak var bookableCheckBox: BEMCheckBox!
    
    @IBOutlet weak var addMenuButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var storeNameTF: UITextField!
    @IBOutlet weak var accountNumberTF: UITextField!
    @IBOutlet weak var requiredCouponTF: UITextField!
    @IBOutlet weak var menuTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    
    let ref: DatabaseReference = Database.database().reference()
    var refHandle: DatabaseHandle?
    var listenerHandle: AuthStateDidChangeListenerHandle?
    let informOwner :InformOwner = InformOwner()
    let uid = Auth.auth().currentUser?.uid
    
    var storeMenuList = [StoreMenuForTableView]()
    
    var isFirst:Bool?
    
    var storeCodeNotFirst = ""
    
    let colors = Colors()
    override func viewDidLoad() {
        super.viewDidLoad()
        //delegate
        storeNameTF.delegate = self
        accountNumberTF.delegate = self
        requiredCouponTF.delegate = self
        menuTF.delegate = self
        priceTF.delegate = self
        
        tableview.delegate = self
        tableview.dataSource = self
        //delegate end
        
        //design
        //status bar
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.backgroundColor = colors.colorPrimary
        statusBar.snp.makeConstraints({ (m) in
            m.right.top.left.equalTo(self.view)
            m.height.equalTo(20)
        })
        //status bar end
        view.backgroundColor = colors.colorPrimary
        tableview.backgroundColor = colors.colorPrimary
        
        let edgeInsets:CGFloat = 8
        addMenuButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        addMenuButton.layer.cornerRadius = 18
        addMenuButton.layer.shadowOpacity = 0.3
        addMenuButton.layer.shadowRadius = 2
        addMenuButton.layer.shadowColor = UIColor.black.cgColor
        addMenuButton.layer.shadowOffset = CGSize(width: 0, height: 0)

        startButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        startButton.layer.cornerRadius = 25
        startButton.layer.shadowOpacity = 0.3
        startButton.layer.shadowRadius = 2
        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        backButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        backButton.layer.cornerRadius = 25
        backButton.layer.shadowOpacity = 0.3
        backButton.layer.shadowRadius = 2
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        //design end
        
        bookableCheckBox.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !isFirst!{
            self.requiredCouponTF.isUserInteractionEnabled = false
            ref.child("users/owner/\(uid!)/inform").observeSingleEvent(of: .value, with: { (snapshot) in
                let userDict = snapshot.value as? [String : AnyObject] ?? [:]
                self.informOwner.setValuesForKeys(userDict)
                self.storeCodeNotFirst = self.informOwner.getStoreCode()
                self.storeNameTF.text = self.informOwner.getStoreName()
                self.requiredCouponTF.text = "\(self.informOwner.getRequiredCoupon())"
                self.accountNumberTF.text = self.informOwner.getAccountNum()
                for (food, price) in (self.informOwner.storeMenu!){
                    self.storeMenuList.append(StoreMenuForTableView(food: food, price: price))
                }
                if self.informOwner.bookable {
                    self.bookableCheckBox.on = true
                }
                DispatchQueue.global(qos: .background).async {
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                }
            })
        }
        
    }
    
    //keyboard controll
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    //keyboard controll end
    
    //text field controol
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == storeNameTF {
            requiredCouponTF.becomeFirstResponder()
        }else if textField == requiredCouponTF {
            menuTF.becomeFirstResponder()
        }else if textField == menuTF {
            priceTF.becomeFirstResponder()
        }else if textField == priceTF {
            priceTF.resignFirstResponder()
        }
        return true
    }
    //text field controol end
    
    //table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeMenuList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "Cell") as! UpdateInformOwnerTableViewCell
        
        cell.cellView.layer.cornerRadius = 8
        cell.cellView.layer.shadowRadius = 2
        
        cell.foodLabel?.text = storeMenuList[indexPath.row].food.capitalized
        cell.priceLabel?.text = "\(storeMenuList[indexPath.row].price)원"
        return cell
    }
    //animation
    func addCell(_ addStoreMenu:StoreMenuForTableView) {
        let index = 0
        storeMenuList.insert(addStoreMenu, at: index)
        
        let indexPath = IndexPath(row: index, section:0)
        tableview.insertRows(at: [indexPath], with: .left)
    }
    //delete and animation
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        storeMenuList.remove(at: indexPath.row)
        tableview.deleteRows(at: [indexPath], with: .automatic)
    }
    //table view end
    
    @IBAction func addStoreMenuButtonAction(_ sender: Any) {
        if (menuTF.text! != "" && priceTF.text! != ""){
            addCell(StoreMenuForTableView(food: menuTF.text!, price: Int(priceTF.text!)!))
            //        self.tableview.reloadData()
            menuTF.text?.removeAll()
            priceTF.text?.removeAll()
        }else{
            let alert = UIAlertController(title: "주의", message: "메뉴와 가격을 모두 입력해주세요.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func checkButtonAction(_ sender: Any) {
        if (storeNameTF.hasText && accountNumberTF.hasText &&
            requiredCouponTF.hasText && !storeMenuList.isEmpty){
            
            

            if isFirst!{
                let storeName = storeNameTF.text!
                let accountNum = accountNumberTF.text!
                let requiredCoupon = Int(requiredCouponTF.text!)!
                var storeMenu = [String:Int]()
                for temp in storeMenuList{
                    storeMenu[temp.food] = temp.price
                }
                
                //random storeCode
                var uuid = UUID().uuidString
                print(uuid)
                let range = uuid.index(uuid.endIndex, offsetBy: -13)..<uuid.endIndex
                uuid.removeSubrange(range)
                let result = uuid.components(separatedBy: ["-"]).joined()
                
                let now=NSDate()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let stringDate = dateFormatter.string(from: now as Date)
                var result2 = stringDate.components(separatedBy: ["-",":"," "]).joined()
                result2.remove(at: result2.index(before: result2.endIndex))
                let storeCode = result+result2
                //random storeCode end
                
                ref.child("users/owner/\(uid!)/inform").setValue(["accountNum":accountNum,
                                                                  "requiredCoupon":requiredCoupon,
                                                                  "storeName":storeName,
                                                                  "storeMenu":storeMenu,
                                                                  "storeCode":storeCode,
                                                                  "storeIntro":"Hello Food!",
                                                                  "storeImage":0,
                                                                  "bookable":bookableCheckBox.on])
                ref.child("stores").child(storeCode).child("inform").setValue(["accountNum":accountNum,
                                                                               "requiredCoupon":requiredCoupon,
                                                                               "storeName":storeName,
                                                                               "storeMenu":storeMenu,
                                                                               "storeCode":storeCode,
                                                                               "storeIntro":"Hello Food!",
                                                                               "storeImage":0,
                                                                               "bookable":bookableCheckBox.on])
           
                
                self.presentingViewController?.presentingViewController?.dismiss(animated: true)
            }else{
                let storeName = storeNameTF.text!
                let accountNum = accountNumberTF.text!
                let requiredCoupon = Int(requiredCouponTF.text!)!
                var storeMenu = [String:Int]()
                for temp in storeMenuList{
                    storeMenu[temp.food] = temp.price
                }
                if bookableCheckBox.on{
                    ref.child("users/owner/\(uid!)/inform").updateChildValues(["storeName":storeName,
                                                                               "requiredCoupon":requiredCoupon,
                                                                               "accountNum":accountNum,
                                                                               "storeMenu":storeMenu,
                                                                               "bookable":true])
                    ref.child("stores/\(storeCodeNotFirst)/inform").updateChildValues(["storeName":storeName,
                                                                                       "requiredCoupon":requiredCoupon,
                                                                                       "accountNum":accountNum,
                                                                                       "storeMenu":storeMenu,
                                                                                       "bookable":true])
                }else{
                    ref.child("users/owner/\(uid!)/inform").updateChildValues(["storeName":storeName,
                                                                               "requiredCoupon":requiredCoupon,
                                                                               "accountNum":accountNum,
                                                                               "storeMenu":storeMenu,
                                                                               "bookable":false])
                    ref.child("stores/\(storeCodeNotFirst)/inform").updateChildValues(["storeName":storeName,
                                                                                       "requiredCoupon":requiredCoupon,
                                                                                       "accountNum":accountNum,
                                                                                       "storeMenu":storeMenu,
                                                                                       "bookable":false])
                }
                
                self.dismiss(animated: true)
            }
            
            
        }else{
            let alert = UIAlertController(title: "알림", message: "세부정보를 모두 입력해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
