//
//  LPUtils.swift
//  LPPage
//
//  Created by lipeng on 2017/11/20.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

public typealias LPIndex = Int

public extension UIScreen {
    static let lp_width = UIScreen.main.bounds.width
    static let lp_height = UIScreen.main.bounds.height
}

extension UIViewController {
    
    /// statusBar高 + navigationBar高（如果navigationBar为nil，则高度为0.0）
    public var lp_topSafeArea: CGFloat {
        var height = UIApplication.shared.statusBarFrame.height
        if let nav = navigationController {
            height += nav.navigationBar.frame.height
        }
        return height
    }
    
}
