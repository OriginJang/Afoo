//
//  DistributedCoupon.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 21..
//  Copyright © 2018년 jang. All rights reserved.
//

import Foundation

@objcMembers class DistributedCoupon:NSObject {
    
    var code: String = ""
    var userUid:String = ""
    var userKey:String = ""
    var dtime:String = ""
    var orderedMenu = [String:Int]()
    var numOfCoupon:Int = 0
    var order:Int = 0
    var used:Int = 0
    var available:Int = 0
    var couponKey:String = ""
    var displayName:String = ""
    
    init(code:String, dtime:String, orderedMenu:[String:Int], numOfCoupon:Int,
         order:Int, used:Int, available:Int, displayName:String) {
        self.code = code
        self.dtime = dtime
        self.orderedMenu = orderedMenu
        self.numOfCoupon = numOfCoupon
        self.order = order
        self.used = used
        self.available = available
        self.displayName = displayName
    }
    
    init(orderedMenu:[String:Int]) {
        self.orderedMenu = orderedMenu
    }
    override init() {
        
    }
    
    func toString() -> String{
        if(self.orderedMenu.isEmpty){
            return "주문 시각\n" + self.dtime + "\n";
        }
        
        var msg:String = ""
        
        for (food, num) in self.orderedMenu{
            msg += "\(food)=\(num),"
        }
        msg.removeLast()
        return "주문 시각\n\(dtime) \n\n주문 내역\n\(msg) "
    }
    
    func menuList( orderedMenu: [String:Int] ) -> [String:String]{
        if(orderedMenu.isEmpty){
            return ["메뉴":"주문된 메뉴가 없습니다."];
        }
        
        var msg:String = ""
        
        for (food, num) in orderedMenu{
            msg += "\(food)=\(num),"
        }
        msg.removeLast()
        return ["메뉴":msg]
    }
    
    func getDisplayName() -> String {
        return self.displayName
    }
    
    func setDisplayName(displayName:String) {
        self.displayName = displayName
    }
    
    func getCouponKey()->String {
    return self.couponKey
    }
    
    func setCouponKey(couponKey:String) {
    self.couponKey = couponKey
    }
    
    func getDtime() -> String {
    return self.dtime
    }
    
    func setDtime(dtime:String) {
    self.dtime = dtime
    }
    
    func getUserKey()->String {
    return self.userKey
    }
    
    func setUserKey(userKey:String) {
    self.userKey = userKey
    }
    
    func getNumOfCoupon()->Int {
    return self.numOfCoupon
    }
    
    func setNumOfCoupon(numOfCoupon:Int) {
    self.numOfCoupon = numOfCoupon
    }
    
    func getCode() ->String {
    return self.code
    }
    
    func setCode(code:String) {
    self.code = code
    }
    
    func getUserUid() ->String{
    return userUid;
    }
    
    func setUserUid(userUid:String) {
    self.userUid = userUid
    }
    
    func getOrderedMenu() -> [String: Int]{
    return self.orderedMenu
    }
    
    func setOrderedMenu(orderedMenu:[String: Int] ) {
    self.orderedMenu = orderedMenu
    }
    
    func getOrder() -> Int {
    return self.order
    }
    
    func setOrder(order:Int) {
    self.order = order
    }
    
    func getUsed() -> Int {
    return self.used
    }
    
    func setUsed(used:Int) {
    self.used = used
    }
    
    func getAvailable() -> Int {
    return self.available
    }
    
    func setAvailable(available:Int) {
    self.available = available
    }
    
}
