//
//  NotificationViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 21..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import Firebase

class NotificationViewController: UIViewController {

    @IBOutlet weak var dtimeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    let ref: DatabaseReference = Database.database().reference()
    let notice :Notice = Notice()
    
    let colors :Colors = Colors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.colorPrimary
        
        let edgeInsets:CGFloat = 8
        backButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        backButton.layer.cornerRadius = 25
        backButton.layer.shadowOpacity = 0.3
        backButton.layer.shadowRadius = 2
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        ref.child("notices").observeSingleEvent(of: .value) { (snapshot) in
            let noticeDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.notice.setValuesForKeys(noticeDict)
            self.titleLabel.text = self.notice.getTitle()
            self.contentLabel.text = self.notice.getContent()
            self.dtimeLabel.text = self.notice.getDtime()
            
        }
        
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
