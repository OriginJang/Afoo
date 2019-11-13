//
//  UsedCoupon.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 7..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import FirebaseDatabase

@objcMembers class UsedCoupon: NSObject {

    var userUid:String
    var dtime:String
    
    init(userUid:String, dtime:String) {
        self.userUid = userUid
        self.dtime = dtime
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String:Any] else { return nil }
        guard let userUid  = dict["userUid"] as? String  else { return nil }
        guard let dtime = dict["dtime"]  as? String else { return nil }
        
        self.userUid = userUid
        self.dtime = dtime
    }
    
    convenience override init(){
        self.init(userUid:"", dtime:"")
    }
    
    
    func setUserUid(userUid: String) {
        self.userUid = userUid
    }
    func setDtime(dtime: String) {
        self.dtime = dtime
    }
    
    func getUserUid() -> String {
        return self.userUid
    }
    func getDtime() -> String {
        return self.dtime
    }
    
}
