//
//  LPSubViewController.swift
//  Example
//
//  Created by lipeng on 2017/11/10.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

class LPSubViewController: UIViewController {
    
    deinit {
        #if DEBUG
            print("LPSubViewController -> relese memory.")
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("LPSubViewController - > viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("LPSubViewController - > viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("LPSubViewController - > viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("LPSubViewController - > viewDidDisappear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.borderColor = UIColor.purple.cgColor
        view.layer.borderWidth = 2
    }
}
