//
//  UpdateInformCustomerViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 20..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase

class UpdateInformCustomerViewController: UIViewController,BEMCheckBoxDelegate,UITextFieldDelegate {

    @IBOutlet weak var maleCheckBox: BEMCheckBox!
    @IBOutlet weak var FemaleCheckBox: BEMCheckBox!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!

    let ref: DatabaseReference = Database.database().reference()
    var refHandle: DatabaseHandle?
    var listenerHandle: AuthStateDidChangeListenerHandle?
    var isFirst:Bool?
    let uid = Auth.auth().currentUser?.uid
    
    let informCustomer : InformCustomer = InformCustomer()
    
    let colors = Colors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.colorPrimary
        maleCheckBox.delegate = self
        FemaleCheckBox.delegate = self
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneNumberTextField.delegate = self
        majorTextField.delegate = self
        
        maleCheckBox.onAnimationType = .oneStroke
        FemaleCheckBox.onAnimationType = .oneStroke
        
        maleCheckBox.on = true
        
        nameTextField.text = Auth.auth().currentUser?.displayName
        emailTextField.text = Auth.auth().currentUser?.email
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !isFirst!{
            self.ref.child("users/customer/\(self.uid!)/inform").observeSingleEvent(of: .value, with: { (snapshot) in
                let userDict = snapshot.value as? [String : AnyObject] ?? [:]
                self.informCustomer.setValuesForKeys(userDict)
                self.nameTextField.text = self.informCustomer.getName()
                self.emailTextField.text = self.informCustomer.getEmail()
                self.phoneNumberTextField.text = "\(self.informCustomer.getPhoneNumber())"
                self.majorTextField.text = self.informCustomer.getMajor()
                if self.informCustomer.getSex() != "Male"{
                    self.maleCheckBox.setOn(false, animated: true)
                    self.FemaleCheckBox.setOn(true, animated: true)
                }
            })
        }
        
    }

    //text field controol
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
        }else if textField == emailTextField {
            textField.resignFirstResponder()
        }else if textField == majorTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    //text field controol end
   
    //keyboard controll
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    //keyboard controll end
    
    @IBAction func maleCheckBoxAction(_ sender: Any) {
        maleCheckBox.setOn(true, animated: true)
        FemaleCheckBox.setOn(false, animated: true)
    }

    @IBAction func femailCheckBoxAction(_ sender: Any) {
        maleCheckBox.setOn(false, animated: true)
        FemaleCheckBox.setOn(true, animated: true)
    }
    @IBAction func startButtonAction(_ sender: Any) {
        if (emailTextField.hasText && majorTextField.hasText && nameTextField.hasText && phoneNumberTextField.hasText){
            
            
            if isFirst!{
                let email = emailTextField.text!
                let major = majorTextField.text!
                let name = nameTextField.text!
                let temp = phoneNumberTextField.text!
                let phoneNumber = temp.components(separatedBy: ["-"]).joined()
                var sex:String = ""
                if maleCheckBox.on {
                    sex = "Male"
                }else{
                    sex = "Female"
                }
                
                
                ref.child("users/customer/\(self.uid!)/inform").setValue(["email":email,
                                                                          "major":major,
                                                                          "name":name,
                                                                          "phoneNumber":phoneNumber,
                                                                          "sex":sex])
                self.presentingViewController?.presentingViewController?.dismiss(animated: true)
            }else{
                let email = emailTextField.text!
                let major = majorTextField.text!
                let name = nameTextField.text!
                let temp = phoneNumberTextField.text!
                let phoneNumber = temp.components(separatedBy: ["-"]).joined()
                var sex:String = ""
                if maleCheckBox.on {
                    sex = "Male"
                }else{
                    sex = "Female"
                }
                
                
                ref.child("users/customer/\(self.uid!)/inform").updateChildValues(["email":email,
                                                                                   "major":major,
                                                                                   "name":name,
                                                                                   "phoneNumber":phoneNumber,
                                                                                   "sex":sex])
                self.dismiss(animated: true)
            }
        }else{
            let alert = UIAlertController(title: "알림", message: "세부정보를 모두 입력해 주세요.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
