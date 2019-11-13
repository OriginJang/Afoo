//
//  Coupon.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 1..
//  Copyright © 2018년 jang. All rights reserved.
//

import Foundation
import FirebaseDatabase

@objcMembers class Coupon: NSObject {
    
    var storeName:String
    var storeCode:String
    var numOfCoupon:Int
    var requiredCoupon:Int
    var usage:Int
    
    init(storeName:String, storeCode:String, requiredCoupon:Int,numOfCoupon:Int, usage:Int) {
        self.storeName = storeName
        self.storeCode = storeCode
        self.requiredCoupon = requiredCoupon
        self.numOfCoupon = numOfCoupon
        self.usage = usage
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String:Any] else { return nil }
        guard let storeName  = dict["storeName"] as? String  else { return nil }
        guard let storeCode = dict["storeCode"]  as? String else { return nil }
        guard let requiredCoupon = dict["requiredCoupon"]  as? Int else { return nil }
        guard let numOfCoupon = dict["numOfCoupon"]  as? Int else { return nil }
        guard let usage = dict["usage"] as? Int else { return nil }
        
        self.storeName = storeName
        self.storeCode = storeCode
        self.requiredCoupon = requiredCoupon
        self.numOfCoupon = numOfCoupon
        self.usage = usage
    }
    
    convenience override init(){
        self.init(storeName : "", storeCode: "", requiredCoupon : 0,numOfCoupon : 0, usage : 0 )
    }
    
    func getStoreName() -> String {
        return self.storeName
    }
    func getStoreCode() -> String {
        return self.storeCode
    }
    func getNumOfCoupon() -> Int {
        return self.numOfCoupon
    }
    func getRequiredCoupon() -> Int {
        return self.requiredCoupon
    }
    func getUsage() -> Int {
        return self.usage
    }
    
    func setStoreName(storeName:String){
        self.storeName = storeName
    }
    func setStoreCode(storeCode:String){
        self.storeCode = storeCode
    }
    func setNumOfCoupon(numOfCoupon:Int) {
        self.numOfCoupon = numOfCoupon
    }
    func setRequiredCoupon(requiredCoupon:Int) {
        self.requiredCoupon = requiredCoupon
    }
    func setUsage(usage: Int) {
        self.usage = usage
    }
    
}

