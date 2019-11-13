//
//  WaitingOrder.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 4..
//  Copyright © 2018년 jang. All rights reserved.
//

import Foundation
import FirebaseDatabase

@objcMembers class WaitingOrder: NSObject {

    var storeName:String
    var storeCode:String
    var dtime:String
    var order:Int
    var alert:Int
    var numOfCoupon:Int
    var requiredCoupon:Int
    
    let BEFORE_GENERAL_ORDER_NOTIFICATION:Int = 0
    let AFTER_GENERAL_ORDER_NOTIFICATION:Int = 1
    let BEFORE_RESERVATION_ORDER_NOTIFICATION:Int = -1
    let CANCEL_RESERVATION_ORDER_NOTIFICATION:Int = -2
    let ERROR_ORDER:Int = -3
    
    init(storeName:String, storeCode:String, dtime:String,order:Int, alert:Int,numOfCoupon:Int, requiredCoupon:Int) {
        self.storeName = storeName
        self.storeCode = storeCode
        self.dtime = dtime
        self.order = order
        self.alert = alert
        self.numOfCoupon = numOfCoupon
        self.requiredCoupon = requiredCoupon
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String:Any] else { return nil }
        guard let storeName  = dict["storeName"] as? String  else { return nil }
        guard let storeCode = dict["storeCode"]  as? String else { return nil }
        guard let dtime = dict["dtime"]  as? String else { return nil }
        guard let order = dict["order"]  as? Int else { return nil }
        guard let alert = dict["alert"]  as? Int else { return nil }
        guard let numOfCoupon = dict["numOfCoupon"]  as? Int else { return nil }
        guard let requiredCoupon = dict["requiredCoupon"]  as? Int else { return nil }
        
        self.storeName = storeName
        self.storeCode = storeCode
        self.dtime = dtime
        self.order = order
        self.alert = alert
        self.numOfCoupon = numOfCoupon
        self.requiredCoupon = requiredCoupon
    }
    
    convenience override init(){
        self.init(storeName : "", storeCode: "", dtime : "",order : 0,alert : 0, numOfCoupon:0, requiredCoupon:0)
    }
    
    func getStoreName() -> String {
        return self.storeName
    }
    func getStoreCode() -> String {
        return self.storeCode
    }
    func getDtime() -> String {
        return self.dtime
    }
    func getOrder() -> Int {
        return self.order
    }
    func getAlert() -> Int {
        return self.alert
    }
    func getNumOfCoupon() -> Int {
        return self.numOfCoupon
    }
    func getRequiredCoupon() -> Int {
        return self.requiredCoupon
    }
    
    func setStoreName(storeName:String){
        self.storeName = storeName
    }
    func setStoreCode(storeCode:String){
        self.storeCode = storeCode
    }
    func setDtime(dtime:String){
        self.dtime = dtime
    }
    func setOrder(order:Int){
        self.order = order
    }
    func setAlert(alert:Int){
        self.alert = alert
    }
    func setNumOfCoupon(numOfCoupon:Int){
        self.numOfCoupon = numOfCoupon
    }
    func setRequiredCoupon(requiredCoupon:Int){
        self.requiredCoupon = requiredCoupon
    }

}
