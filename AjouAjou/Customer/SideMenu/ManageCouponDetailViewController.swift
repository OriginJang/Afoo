//
//  ManageCouponDetailViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 5..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase

class ManageCouponDetailViewController: UIViewController {


    @IBOutlet weak var numOfCouponLabel: UILabel!
    
    var imageViewList = [UIImageView]()
    var coupon:Coupon = Coupon()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var count = coupon.getRequiredCoupon()
        let numOfCoupon = coupon.getNumOfCoupon()
        var couponCount = coupon.getNumOfCoupon()

        
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width //화면 너비
        let height = bounds.size.height //화면 높이
        let y = Int(height/2) - 20
        
        if couponCount > 11{
            couponCount = 10
        }
        if count > 11{
            count = 10
        }
        
        if width <= 320 {
            for i in 0 ..< count{
                let imgView = UIImageView()
                if i < 5{
                    imgView.image = UIImage(named: "couponIconEmptyGray.png")
                    imgView.frame = CGRect(x: 50*i+50, y: y, width: 40, height: 40)
                    self.view.addSubview(imgView)
                    imageViewList.append(imgView)
                }else if( i >= 5 && i < 9 ) {
                    imgView.image = UIImage(named: "couponIconEmptyGray.png")
                    imgView.frame = CGRect(x: 50*(i-5)+50, y: y + 50, width: 40, height: 40)
                    self.view.addSubview(imgView)
                    imageViewList.append(imgView)
                }else{
                    imgView.image = UIImage(named: "couponIconFullGray.png")
                    imgView.frame = CGRect(x: 50*(i-5)+50, y: y + 50, width: 40, height: 40)
                    self.view.addSubview(imgView)
                    imageViewList.append(imgView)
                }
            }

//            for i in 0 ..< couponCount {
//                let imgView = UIImageView()
//                if i < 5{
//                    imgView.image = UIImage(named: "couponIconEmptyColor.png")
//                    imgView.frame = CGRect(x: 50*i+50, y: y, width: 40, height: 40)
//                    self.view.addSubview(imgView)
//                    imageViewList.append(imgView)
//                }else if( i >= 5 && i < 10 ) {
//                    imgView.image = UIImage(named: "couponIconEmptyColor.png")
//                    imgView.frame = CGRect(x: 50*(i-5)+50, y: y + 50, width: 40, height: 40)
//                    self.view.addSubview(imgView)
//                    imageViewList.append(imgView)
//                }else{
//                    imgView.image = UIImage(named: "couponIconFullColor.png")
//                    imgView.frame = CGRect(x: 50*(i-5)+50, y: y + 50, width: 40, height: 40)
//                    self.view.addSubview(imgView)
//                    imageViewList.append(imgView)
//                }
//            }
        }else{
            for i in 0 ..< count{
                let imgView = UIImageView()
                if i < 5{
                    imgView.image = UIImage(named: "couponIconEmptyGray.png")
                    imgView.frame = CGRect(x: 50*i+90, y: y, width: 40, height: 40)
                    self.view.addSubview(imgView)
                    imageViewList.append(imgView)
                }else if(i >= 5 && i < 9){
                    imgView.image = UIImage(named: "couponIconEmptyGray.png")
                    imgView.frame = CGRect(x: 50*(i-5)+90, y: y + 50, width: 40, height: 40)
                    self.view.addSubview(imgView)
                    imageViewList.append(imgView)
                }else{
                    imgView.image = UIImage(named: "couponIconFullGray.png")
                    imgView.frame = CGRect(x: 50*(i-5)+90, y: y + 50, width: 40, height: 40)
                    self.view.addSubview(imgView)
                    imageViewList.append(imgView)
                }
            }
            
            
            //counted coupon set
            for i in 0 ..< couponCount {
                let imgView = UIImageView()
                if i < 5{
                    imgView.image = UIImage(named: "couponIconEmptyColor.png")
                    imgView.frame = CGRect(x: 50*i+90, y: y, width: 40, height: 40)
                    self.view.addSubview(imgView)
                    imageViewList.append(imgView)
                }else if(i >= 5 && i < 9){
                    imgView.image = UIImage(named: "couponIconEmptyColor.png")
                    imgView.frame = CGRect(x: 50*(i-5)+90, y: y + 50, width: 40, height: 40)
                    self.view.addSubview(imgView)
                    imageViewList.append(imgView)
                }else{
                    imgView.image = UIImage(named: "couponIconFullColor.png")
                    imgView.frame = CGRect(x: 50*(i-5)+90, y: y + 50, width: 40, height: 40)
                    self.view.addSubview(imgView)
                    imageViewList.append(imgView)
                }
            }
        }
        
        

        numOfCouponLabel.text = "사용가능한 쿠폰: \(numOfCoupon)"
        
    }
    
    
    @IBAction func createQRButtonAction(_ sender: Any) {
        
        if (coupon.getNumOfCoupon() < coupon.getRequiredCoupon()){
            let alert = UIAlertController(title: "알림", message: "쿠폰 개수를 확인해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
            
            self.present(alert, animated: true, completion: nil)
        }else{
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createUsingCouponQRSegue"{
            let nextVC = segue.destination as! MakeQRCodeToUseCouponViewController
            nextVC.coupon = self.coupon
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
