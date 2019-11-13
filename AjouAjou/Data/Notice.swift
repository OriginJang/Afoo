//
//  Notice.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 21..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import FirebaseDatabase

@objcMembers class Notice: NSObject {
    var title:String
    var content:String
    var dtime:String
    
    init(title:String, content:String, dtime:String) {
        self.title = title
        self.content = content
        self.dtime = dtime
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String:Any] else { return nil }
        guard let title  = dict["title"] as? String  else { return nil }
        guard let content = dict["content"]  as? String else { return nil }
        guard let dtime = dict["dtime"]  as? String else { return nil }
        
        self.title = title
        self.content = content
        self.dtime = dtime
    }
    
    convenience override init(){
        self.init(title:"", content:"", dtime:"")
    }
    
    func getTitle() -> String {
        return self.title
    }
    func getContent() -> String {
        return self.content
    }
    func getDtime() -> String {
        return self.dtime
    }
    
    func setTitleName(title:String){
        self.title = title
    }
    func setContentCode(content:String){
        self.content = content
    }
    func setDtime(dtime:String) {
        self.dtime = dtime
    }
    
}
