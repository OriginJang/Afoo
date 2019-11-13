//
//  CustomerManualPageViewController.swift
//  AjouAjou
//
//  Created by jang on 2018. 2. 17..
//  Copyright © 2018년 jang. All rights reserved.
//

import UIKit

class CustomerManualPageViewController: UIPageViewController, UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    
    lazy var subViewControllers:[UIViewController]={
        return [
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"CustomerManual1ViewController") as! CustomerManual1ViewController,
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"CustomerManual2ViewController") as! CustomerManual2ViewController,
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"CustomerManual3ViewController") as! CustomerManual3ViewController
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        setViewControllers([subViewControllers[0]], direction: .forward, animated: true, completion: nil)

        // Do any additional setup after loading the view.
    }
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int = subViewControllers.index(of: viewController) ?? 0
        if (currentIndex <= 0){
            return nil
        }
        return subViewControllers[currentIndex-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int = subViewControllers.index(of: viewController) ?? 0
        if (currentIndex >= subViewControllers.count - 1){
            return nil
        }
        return subViewControllers[currentIndex+1]
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
