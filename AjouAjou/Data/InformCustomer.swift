//
//  InformationCustomer.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 19..
//  Copyright © 2018년 jang. All rights reserved.
//

import Foundation
import FirebaseDatabase

@objcMembers class InformCustomer:NSObject {
    var email:String
    var name:String
    var major: String
    var phoneNumber: String
    var sex: String
    
    init(email:String, name:String, major: String,phoneNumber: String, sex: String) {
        self.email = email
        self.name = name
        self.major = major
        self.phoneNumber = phoneNumber
        self.sex = sex
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String:Any] else { return nil }
        guard let email  = dict["email"] as? String  else { return nil }
        guard let name = dict["name"]  as? String else { return nil }
        guard let major = dict["major"]  as? String else { return nil }
        guard let phoneNumber = dict["phoneNumber"]  as? String else { return nil }
        guard let sex = dict["sex"] as? String else { return nil }
        
        self.email = email
        self.name = name
        self.major = major
        self.phoneNumber = phoneNumber
        self.sex = sex
    }
    
    convenience override init(){
        self.init(email: "",name: "",major: "",phoneNumber: "" ,sex: "")
    }
    
    
    func setEmail(email:String) {
        self.email = email
    }
    func getEmail() -> String {
        return self.email
    }
    
    func setName(name:String) {
        self.name = name
    }
    func getName() -> String {
        return self.name
    }
    
    func setMajor(major:String) {
        self.major = major
    }
    func getMajor() -> String {
        return self.major
    }
    
    func setPhoneNumber(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    func getPhoneNumber() -> String {
        return self.phoneNumber
    }
    
    func setSex(sex:String) {
        self.sex = sex
    }
    func getSex() -> String {
        return self.sex
    }
}
