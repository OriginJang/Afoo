//
//  OwnerSignUpViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 19..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase

class OwnerSignUpViewController: UIViewController,UITextFieldDelegate {
    let colors = Colors()
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    let ref: DatabaseReference = Database.database().reference()
    var refHandle: DatabaseHandle?
    
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
        
        signUpButton.layer.cornerRadius = 3
        signUpButton.layer.shadowColor = UIColor.black.cgColor
        signUpButton.layer.shadowRadius = 1.5
        signUpButton.layer.shadowOpacity = 0.3
        signUpButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        signUpButton.backgroundColor = colors.colorSecondary
        
        signUpButton.addTarget(self, action: #selector(signUpEvent), for: .touchUpInside)
        
    }
    
    @objc func signUpEvent() {
        let email = emailTextField.text
        let password = passwordTextField.text
        if (email != "" && password != "") {
            if (password!.count < 6){
                let alert = UIAlertController(title: "주의", message: "비밀번호는 6자리 이상 입력해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {(user,error) in
                    if error != nil {
                        if let errCode = AuthErrorCode(rawValue: error!._code) {
                            
                            switch errCode {
                            case AuthErrorCode.invalidEmail:
                                let alert = UIAlertController(title: "알림", message: "이메일 형식을 확인해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
                                self.present(alert, animated: true, completion: nil)
                                
                            case AuthErrorCode.emailAlreadyInUse:
                                let alert = UIAlertController(title: "알림", message: "이미 사용중인 이메일 주소입니다.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
                                self.present(alert, animated: true, completion: nil)
                                
                            case AuthErrorCode.networkError:
                                let alert = UIAlertController(title: "알림", message: "네트워크 연결을 확인해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
                                self.present(alert, animated: true, completion: nil)
                            
                            default:
                                let alert = UIAlertController(title: "알림", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }else{
                        let uid = user?.uid
                        self.ref.child("users").child("owner").child(uid!).child("inform").setValue(["accountNum":"",
                                                                                                     "requiredCoupon":0,
                                                                                                     "storeCode":"",
                                                                                                     "storeMenu":"",
                                                                                                     "storeName":""])
                        self.ref.child("users").child("owner").child(uid!).child("inform").child("storeMenu").setValue(["example":1000])
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                
            }
        }else{
            let alert = UIAlertController(title: "주의", message: "이메일 또는 비밀번호를 입력해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
