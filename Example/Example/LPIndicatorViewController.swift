//
//  LPIndicatorViewController.swift
//  Example
//
//  Created by lipeng on 2017/11/20.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit
import LPPage

class LPIndicatorViewController: LPBasePageViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - LPIndicatorViewDataSource
    
    override func styleForIndicatorView(in pageBar: LPPageBar) -> LPIndicatorStyle? {
        guard let data = data, case .indicator(let indicator) = data.id else { return nil }
        switch indicator {
        case .none: return nil
        case .textWidth:
            let sp = LPStripeFrame(lr: 10, h: 4, b: 5)
            return .stripe(.textWidth(sp), UIColor.orange)
        case .fullWidth:
            return .stripe(.fullWidth(LPStripeFrame()), UIColor.orange)
        case .box:
            return .box(#colorLiteral(red: 0.1411764706, green: 0.8431372549, blue: 0.7843137255, alpha: 1))
        case .arrow:
            return .arrow(LPIndicatorFrame(), UIColor.orange)
        case .custom:
            let imgV = UIImageView(image: #imageLiteral(resourceName: "icon_room"))
            return .custom(imgV, LPIndicatorFrame())
        }
    }
    
}
