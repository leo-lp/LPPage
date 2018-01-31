//
//  LPSafeAreaSubViewController.swift
//  Example
//
//  Created by lipeng on 2017/12/4.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

class LPSafeAreaSubViewController: UIViewController {
    
    deinit {
        #if DEBUG
            print("LPSafeAreaSubViewController -> relese memory.")
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("LPSafeAreaSubViewController - > viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("LPSafeAreaSubViewController - > viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("LPSafeAreaSubViewController - > viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("LPSafeAreaSubViewController - > viewDidDisappear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.borderColor = UIColor.purple.cgColor
        view.layer.borderWidth = 2
    }

}
