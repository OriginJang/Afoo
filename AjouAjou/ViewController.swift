//
//  ViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 15..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController,GIDSignInUIDelegate {
    let colors = Colors()
    
    @IBOutlet weak var spiningView: UIActivityIndicatorView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoLoginImageView: UIImageView!
    @IBOutlet weak var ownerLoginButton: UIButton!
    @IBOutlet weak var customerLoginButton: UIButton!
    @IBOutlet weak var customerButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var customerbuttonHeight: NSLayoutConstraint!
    
    let ref: DatabaseReference = Database.database().reference()
    var refHandle: DatabaseHandle?
    
    var listenerHandle: AuthStateDidChangeListenerHandle?
    var checkUser:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ownerLoginButton.isEnabled = false
        self.customerLoginButton.isEnabled = false
        //view design
        //status bar
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.backgroundColor = colors.colorPrimary
        statusBar.snp.makeConstraints({ (m) in
            m.right.top.left.equalTo(self.view)
            m.height.equalTo(20)
        })
        //status bar end
        
        //items
        logoImageView.image = UIImage(named: "afoo_logo_white.png")
        view.backgroundColor = colors.colorPrimary
        
        let edgeInsets:CGFloat = 12
        let ButtonWidth = customerButtonWidth.constant
        let ButtonHeight = customerbuttonHeight.constant
        let rightEdgeInsets:CGFloat =  ButtonWidth - (ButtonHeight - edgeInsets)
        customerLoginButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: rightEdgeInsets)
        customerLoginButton.layer.cornerRadius = 2
        customerLoginButton.layer.shadowColor = UIColor.black.cgColor
        customerLoginButton.layer.shadowRadius = 2
        customerLoginButton.layer.shadowOpacity = 0.3
        customerLoginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        ownerLoginButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: rightEdgeInsets)
        ownerLoginButton.backgroundColor = colors.colorSecondary
        ownerLoginButton.layer.cornerRadius = 2
        ownerLoginButton.layer.shadowColor = UIColor.black.cgColor
        ownerLoginButton.layer.shadowRadius = 2
        ownerLoginButton.layer.shadowOpacity = 0.3
        ownerLoginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        //items end
        //view design end
        
        
        //google login
        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signIn()
        //google login end
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.ownerLoginButton.isEnabled = false
        self.customerLoginButton.isEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        listenerHandle = Auth.auth().addStateDidChangeListener({(auth, user) in
            if user != nil {
                self.ownerLoginButton.isEnabled = false
                self.customerLoginButton.isEnabled = false
                let userUid = user?.uid
                let userRef = (self.ref).child("users/owner/\(userUid!)")
                
                userRef.observe(.value, with: { (snapshot) in
                    if snapshot.hasChildren() {
                        self.checkUser = "OWNER"
                    }else{
                        self.checkUser = "CUSTOMER"
                    }
                    if (self.checkUser == "CUSTOMER"){
                        self.performSegue(withIdentifier: "CustomerAuthorizedLogin", sender: self)
                    }else if (self.checkUser == "OWNER"){
                        self.performSegue(withIdentifier: "OwnerAuthorizedAutoLogin", sender: self)
                    }
                })
            }else{
                self.checkUser = nil
                self.spiningView.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.ownerLoginButton.isEnabled = true
                    self.customerLoginButton.isEnabled = true
                    self.spiningView.stopAnimating()
                }
                
                
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.spiningView.stopAnimating()
        self.ownerLoginButton.isEnabled = false
        self.customerLoginButton.isEnabled = false
        Auth.auth().removeStateDidChangeListener(listenerHandle!)
    }
    
    @IBAction func customerLoginButtonAction(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

