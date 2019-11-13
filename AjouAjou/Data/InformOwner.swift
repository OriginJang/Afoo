//
//  InformOwner.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 18..
//  Copyright © 2018년 jang. All rights reserved.
//

import Foundation
import FirebaseDatabase

@objcMembers class InformOwner:NSObject {
    var storeName:String
    var accountNum:String
    var requiredCoupon:Int
    var storeMenu:[String:Int]?
    var storeCode:String
    var bookable:Bool
    var storeImage:Int
    var storeIntro:String
    
    
    init(storeName:String, accountNum:String, requiredCoupon:Int,storeMenu: [String:Int], storeCode:String, bookable:Bool, storeImage:Int,storeIntro:String) {
        self.storeName = storeName
        self.accountNum = accountNum
        self.requiredCoupon = requiredCoupon
        self.storeMenu = storeMenu
        self.storeCode = storeCode
        self.bookable = bookable
        self.storeImage = storeImage
        self.storeIntro = storeIntro
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String:Any] else { return nil }
        guard let storeName  = dict["storeName"] as? String  else { return nil }
        guard let accountNum = dict["accountNum"]  as? String else { return nil }
        guard let requiredCoupon = dict["requiredCoupon"]  as? Int else { return nil }
        guard let storeMenu = dict["storeMenu"]  as? [String:Int] else { return nil }
        guard let storeCode = dict["storeCode"] as? String else { return nil }
        guard let bookable = dict["bookable"]  as? Bool else { return nil }
        guard let storeImage = dict["storeImage"]  as? Int else { return nil }
        guard let storeIntro = dict["storeIntro"] as? String else { return nil }
        
        
        self.storeName = storeName
        self.accountNum = accountNum
        self.requiredCoupon = requiredCoupon
        self.storeMenu = storeMenu
        self.storeCode = storeCode
        self.bookable = bookable
        self.storeImage = storeImage
        self.storeIntro = storeIntro
    }
    
    convenience override init(){
        self.init(storeName: "",accountNum: "",requiredCoupon: 0,storeMenu: ["" : 0],storeCode: "", bookable:false , storeImage:0,storeIntro:"")
    }
    
    func getStoreName() -> String {
        return self.storeName
    }
    func getStoreCode() -> String {
        return self.storeCode
    }
    func getAccountNum() -> String {
        return self.accountNum
    }
    func getRequiredCoupon() -> Int {
        return self.requiredCoupon
    }
    func getStoreMenu() -> [String:Int] {
        return self.storeMenu!
    }
    func getBookable() -> Bool {
        return self.bookable
    }
    func getStoreImage() -> Int {
        return self.storeImage
    }
    func getStoreIntro() -> String {
        return self.storeIntro
    }
    
    func setStoreName(storeName:String){
        self.storeName = storeName
    }
    func setStoreCode(storeCode:String){
        self.storeCode = storeCode
    }
    func setAccountNum(accountNum:String) {
        self.accountNum = accountNum
    }
    func setRequiredCoupon(requiredCoupon:Int) {
        self.requiredCoupon = requiredCoupon
    }
    func setStoreMenu(storeMenu: [String:Int]) {
        self.storeMenu = storeMenu
    }
    func setBookable(bookable:Bool) {
        self.bookable = bookable
        
        
    }
    func setStoreImage(storeImage:Int){
        self.storeImage = storeImage
    }
    func setStoreIntro(storeIntro:String){
        self.storeIntro = storeIntro
    }
    
    
}
