//
//  SplashViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 18..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class SplashViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    var box = UIImageView()
    var remoteConfig: RemoteConfig!
    let color = Colors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad!!!!!!!!!!!!!!!!!!!!!!")
        
        //remote controll
        remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings!
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        remoteConfig.fetch(withExpirationDuration: TimeInterval(0)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            self.displayWelcome()
        }
        //remote controll end
        
        //splash image, splash background
        logoImageView.image = UIImage(named: "afoo_logo_white.png")
        self.view.backgroundColor = color.colorPrimary
        //splash image, splash background end
    }

    
    func displayWelcome() {
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        if (caps){
            let alert = UIAlertController(title: "공지사항", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:{ (action) in
                exit(0)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }else{
            let nextView = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.present(nextView, animated: false, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logoImageView.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let duration = 1.0
        let delay = 0.0
        UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
            self.logoImageView.alpha = 1.0
        }, completion: nil)
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
