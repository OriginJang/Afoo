//
//  OwnerLoginViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 15..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class OwnerLoginViewController: UIViewController,UITextFieldDelegate {
    let colors = Colors()

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var ownerLoginButton: UIButton!
    @IBOutlet weak var signUp: UIButton!
    
    
    
    let ref: DatabaseReference = Database.database().reference()
    var refHandle: DatabaseHandle?
    
    var handle: AuthStateDidChangeListenerHandle?
    var checkUser:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        
        //status bar
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.backgroundColor = colors.colorPrimary
        statusBar.snp.makeConstraints({ (m) in
            m.right.top.left.equalTo(self.view)
            m.height.equalTo(20)
        })
        //status bar end
        
        view.backgroundColor = colors.colorPrimary
        
        let edgeInsets:CGFloat = 8
        backButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        backButton.layer.cornerRadius = 20
        backButton.layer.shadowOpacity = 0.5
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        backButton.backgroundColor = colors.colorSecondary
        
        ownerLoginButton.layer.cornerRadius = 3
        ownerLoginButton.layer.shadowColor = UIColor.black.cgColor
        ownerLoginButton.layer.shadowRadius = 2
        ownerLoginButton.layer.shadowOpacity = 0.3
        ownerLoginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        ownerLoginButton.backgroundColor = colors.colorSecondary
        
        
        signUp.layer.cornerRadius = 3
        signUp.layer.shadowColor = UIColor.black.cgColor
        signUp.layer.shadowRadius = 1.5
        signUp.layer.shadowOpacity = 0.3
        signUp.layer.shadowOffset = CGSize(width: 0, height: 2)
        signUp.backgroundColor = colors.colorSecondary
        signUp.addTarget(self, action: #selector(presentSingUp), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        handle = Auth.auth().addStateDidChangeListener({(auth, user) in
            if user != nil {
                let userUid = user?.uid
                let userRef = (self.ref).child("users/owner/\(userUid!)")
                
                userRef.observe(.value, with: { (snapshot) in
                    if snapshot.hasChildren() {
                        self.checkUser = "OWNER"
                    }else{
                        self.checkUser = "CUSTOMER"
                    }
                    if (self.checkUser == "CUSTOMER"){
                        let alert = UIAlertController(title: "알림", message: "잘못된 접근입니다. 다시 로그인 해주세요.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:{ (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        
                    }else if (self.checkUser == "OWNER"){
                        self.performSegue(withIdentifier: "OwnerAuthorizedLogin", sender: self)
                    }
                })
            }else{
                self.checkUser = nil
            }
        })
    }
    
    
    
    
    @IBAction func ownerLoginButtonAction(_ sender: Any) {
        //오너 로그인
        if (emailTextField.text! != "" && passwordTextField.text! != ""){
            let email = emailTextField.text!
            let password = passwordTextField.text!
            print("True")
            if (email != "" && password != ""){
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if error != nil{
                        if let errCode = AuthErrorCode(rawValue: error!._code) {
                            
                            switch errCode {
                            
                            case AuthErrorCode.userNotFound:
                                let alert = UIAlertController(title: "알림", message: "등록되지 않은 이메일입니다.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
                                self.present(alert, animated: true, completion: nil)
                                
                            case AuthErrorCode.invalidEmail:
                                let alert = UIAlertController(title: "알림", message: "이메일 형식을 확인해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
                                self.present(alert, animated: true, completion: nil)
                                
                            case AuthErrorCode.wrongPassword:
                                let alert = UIAlertController(title: "알림", message: "비밀번호가 틀렸습니다.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
                                self.present(alert, animated: true, completion: nil)
                                
                            case AuthErrorCode.userDisabled:
                                let alert = UIAlertController(title: "알림", message: "사용정지된 이메일입니다.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
                                self.present(alert, animated: true, completion: nil)
                            default:
                                let alert = UIAlertController(title: "알림", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    
                    if user == nil{
                        let alert = UIAlertController(title: "알람", message: "아이디 또는 비밀번호를 확인해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
            }
        }else{
            print("False")
            let alert = UIAlertController(title: "알람", message: "아이디 또는 비밀번호를 입력해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        Auth.auth().removeStateDidChangeListener(handle!)
        emailTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }

    
    @objc func presentSingUp() {
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "OwnerSignUpViewController") as! OwnerSignUpViewController
        self.present(nextView, animated: true, completion: nil)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
