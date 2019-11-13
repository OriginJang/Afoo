//
//  ManageCouponViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 5..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase

class ManageCouponViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    var storageList = [[Coupon]]()
    let colors = Colors()
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = colors.colorPrimary
        tableView.backgroundColor = colors.colorPrimary
        
        let edgeInsets:CGFloat = 8
        backButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        backButton.layer.cornerRadius = 18
        backButton.layer.shadowOpacity = 0.3
        backButton.layer.shadowRadius = 2
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        ref.child("users/customer/\(uid!)/storage").observeSingleEvent(of: .value) { (snapshot) in
            self.storageList.removeAll()
            for child in snapshot.children{
                let fchild = child as! DataSnapshot
                let storageCouponDict = fchild.value as? [String : AnyObject] ?? [:]
                let sc = Coupon()
                print(storageCouponDict)
                sc.setValuesForKeys(storageCouponDict)
                self.storageList.append([sc])
            }
            
                
            
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storageList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storageCell") as! ManageCouponTableViewCell
        
        for storageCoupon in storageList[indexPath.row]{
            cell.storeNameLabel.text = storageCoupon.getStoreName()
            cell.numOfCouponLabel.text = "사용가능한 쿠폰: \(storageCoupon.getNumOfCoupon())"
        }
        
        return cell
    }
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "storageDetailSegue"{
            (segue.destination as! ManageCouponDetailViewController).coupon = storageList[self.tableView.indexPathForSelectedRow!.row][0]
        }
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
