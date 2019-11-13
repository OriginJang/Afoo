//
//  QRReaderViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 3. 1..
//  Copyright © 2018년 jang. All rights reserved.
//


import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase
import AudioToolbox

class QRReaderViewController: UIViewController {
    
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var videoPreView: UIView!
    var avCaptureSession:AVCaptureSession!
    
    var check:String = ""
    var qrData = ""
    let coupon : Coupon = Coupon()
    var couponKey:String = ""
    var requiredCoupon:Int = 0
    
    let usedCoupon:UsedCoupon = UsedCoupon()
    var passedStoreCodeToCheck:String = ""
    var storeCode:String = ""
    
    let ref = Database.database().reference()
    
    enum error:Error{
        case noCameraAvailable
        case videoInputInitFail
    }
    
    enum qrDataError:Error{
        case outOfRange
        case videoInputInitFail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.lightGray
        
        let edgeInsets:CGFloat = 8
        backButton.imageEdgeInsets = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        backButton.layer.cornerRadius = 25
        backButton.layer.shadowOpacity = 0.3
        backButton.layer.shadowRadius = 2
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        print(check)
        
        do {
            try scanQRCode()
            print("QR 스캔중")
        } catch  {
            print("QR scan fail")
        }
        self.videoPreView.bringSubview(toFront: msgView)
        // Do any additional setup after loading the view.
    }
    
    
    //    private func metadataOutput(_ output: AVCaptureOutput!, didOutput metadataObjects:[AVMetadataObject], from connection: AVCaptureConnection!)  {
    //        if metadataObjects.count > 0 {
    //            let machineReadableCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
    //            if machineReadableCode.type == AVMetadataObject.ObjectType.qr{
    //                qrData = machineReadableCode.stringValue!
    //                print("It works")
    //            }
    //        }
    //        print("!!!!!!!!!!!!!!!")
    //    }
    
    func scanQRCode() throws {
        avCaptureSession = AVCaptureSession()
        
        guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("No camera.")
            self.navigationController?.popViewController(animated: true)
            throw error.noCameraAvailable
        }
        
        
        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else {
            print("failed to init camera.")
            throw error.videoInputInitFail
        }
        
        let avCaptureMetadataOutput = AVCaptureMetadataOutput()
        
        avCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        self.avCaptureSession.addInput(avCaptureInput)
        self.avCaptureSession.addOutput(avCaptureMetadataOutput)
        
        avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.frame = videoPreView.bounds
        self.videoPreView.layer.addSublayer(avCaptureVideoPreviewLayer)
        self.videoPreView.bringSubview(toFront: backButton)
        self.avCaptureSession.startRunning()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.avCaptureSession.stopRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "customerQrSegue"{
            guard let CustomerQRDataVC = segue.destination as? CustomerQRDataViewController else { return }
            print("qrDate: \(self.qrData)")
            CustomerQRDataVC.couponKey = self.couponKey
            CustomerQRDataVC.coupon = self.coupon
        }else if segue.identifier == "ownerQrSegue"{
            guard let OwnerQRDataVC = segue.destination as? OwnerQRDateViewController else { return }
            print("qrDate: \(self.qrData)")
            OwnerQRDataVC.usedCoupon = self.usedCoupon
            OwnerQRDataVC.storeCode = self.storeCode
            OwnerQRDataVC.requiredCoupon = self.requiredCoupon
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonActoion(_ sender: Any) {
        self.avCaptureSession.stopRunning()
        dismiss(animated: true,completion: nil)
    }
    
    func makeQrData(temp:[Substring]) throws  {
        self.couponKey = "\(temp[0])"
        self.coupon.setUsage(usage: 0)
        self.coupon.setStoreCode(storeCode: "\(temp[2])")
        self.coupon.setNumOfCoupon(numOfCoupon: Int(temp[3])!)
        self.coupon.setRequiredCoupon(requiredCoupon: Int(temp[4])!)
        self.coupon.setStoreName(storeName: "")
    }
    

   
}

extension QRReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func isNumeric(_ s: String) -> Bool {
        let set = CharacterSet.decimalDigits
        for us in s.unicodeScalars where !set.contains(us) { return false }
        return true
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        
        // Get the metadata object.
        if metadataObjects.count == 0 {
            
            print( "No QR code is detected")
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            
            if metadataObj.stringValue != nil {
                if check == "CUSTOMER"{
                    self.qrData = metadataObj.stringValue!
                    var temp = qrData.split(separator: ":")
                    print("coupon array:\(temp)")
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    if temp.count != 5{
                        self.avCaptureSession.stopRunning()
                        let alert = UIAlertController(title: "알림", message: "올바른 QR코드가 아닙니다.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:{ (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)

                    }else{
                        if (isNumeric("\(temp[3])") && isNumeric("\(temp[4])")){
                            couponKey = "\(temp[0])"
                            coupon.setUsage(usage: 0)
                            coupon.setStoreCode(storeCode: "\(temp[2])")
                            coupon.setNumOfCoupon(numOfCoupon: Int(temp[3])!)
                            coupon.setRequiredCoupon(requiredCoupon: Int(temp[4])!)
                            coupon.setStoreName(storeName: "")
    
                            performSegue(withIdentifier: "customerQrSegue", sender: nil)
                            self.avCaptureSession.stopRunning()
                        }else{
                            self.avCaptureSession.stopRunning()
                            let alert = UIAlertController(title: "알림", message: "올바른 QR코드가 아닙니다.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:{ (action) in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }else if check == "OWNER"{
                    self.qrData = metadataObj.stringValue!
                    var temp = qrData.split(separator: "=")
                    print("usedCoupon array:\(temp)")
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    if temp.count != 3{
                        self.avCaptureSession.stopRunning()
                        let alert = UIAlertController(title: "알림", message: "올바른 QR코드가 아닙니다.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:{ (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }else{
                        self.avCaptureSession.stopRunning()
                        usedCoupon.setUserUid(userUid: "\(temp[0])")
                        storeCode = "\(temp[1])"
                        usedCoupon.setDtime(dtime: "\(temp[2])")
                        print(self.storeCode)
                        
                        ref.child("stores/\(self.storeCode)/inform/requiredCoupon").observeSingleEvent(of: .value, with: { (snapshot) in
                            print(snapshot.value)
                            self.requiredCoupon = snapshot.value as! Int
                            
                            self.performSegue(withIdentifier: "ownerQrSegue", sender: nil)
                            
                        })
                        
                    }
                    
                }else{
                    let alert = UIAlertController(title: "알림", message: "잘못된 접속입니다.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler:{ (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
}

