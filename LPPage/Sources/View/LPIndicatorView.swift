//
//  LPIndicatorView.swift
//  LPPage
//
//  Created by lipeng on 2017/11/21.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

/// 用来配置条形的Indicator的Frame
public struct LPStripeFrame {
    /// 设置Stripe的左右间距；默认0.0
    public var lrSpacing: CGFloat = 0.0
    
    /// 设置Stripe的高度；默认2.0
    public var height: CGFloat = 2.0
    
    /// 设置Stripe的下间距；默认0.0
    public var bottom: CGFloat = 0.0
    
    public init() { }
    public init(lr: CGFloat, h: CGFloat, b: CGFloat) {
        lrSpacing = lr
        height = h
        bottom = b
    }
}

/// 用来设置Indicator的Frame
public struct LPIndicatorFrame {
    /// 设置Indicator的宽高；默认宽12.0高8.0
    public var size: CGSize = CGSize(width: 12.0, height: 6.0)
    /// 设置Indicator的下间距；默认0.0
    public var bottom: CGFloat = 0.0
    
    public init() { }
    public init(s: CGSize, b: CGFloat) {
        size = s
        bottom = b
    }
    public init(w: CGFloat, h: CGFloat, b: CGFloat) {
        size = CGSize(width: w, height: h)
        bottom = b
    }
}

/// 用来配置条形的Indicator的样式
///
/// - textWidth: Indicator将和Text等宽；可用LPStripeFrame设置左、右、下间距和高度
/// - FullWidth: Indicator的宽度将填充整个BarItem；可用LPStripeFrame设置左、右、下间距和高度
public enum LPStripe {
    case textWidth(LPStripeFrame)
    case fullWidth(LPStripeFrame)
}

/// 可设置Indicator样式
///
/// - stripe: 条形的Indicator；stripe配置详情请参照“LPStripe”
/// - box: 矩形的Indicator，宽高填充整个BarItem
/// - arrow: 方向朝上的箭头
/// - custom: 可定制Indicator
public enum LPIndicatorStyle {
    case stripe(LPStripe, UIColor)
    case box(UIColor)
    case arrow(LPIndicatorFrame, UIColor)
    case custom(UIView, LPIndicatorFrame)
}

class LPIndicatorView: UIView {
    /// Indicator的样式；默认.stripe(.textWidth(LPStripeFrame()), UIColor.orange)
    private(set) var style: LPIndicatorStyle = .stripe(.textWidth(LPStripeFrame()), UIColor.orange)
    
    deinit {
        #if DEBUG
            print("LPIndicatorView -> relese memory.")
        #endif
    }
    
    convenience init(style: LPIndicatorStyle) {
        self.init(frame: .zero)
        self.style = style
        
        switch style {
        case .stripe(_, let color), .box(let color):
            backgroundColor = color
        case .arrow:
            backgroundColor = UIColor.clear
            setNeedsDisplay()
        case .custom(let view, _):
            backgroundColor = UIColor.clear
            addSubview(view)
        }
    }
    
    /// 更新Indicator的Frame
    ///
    /// - Parameter item: 当前选中状态的BarItem
    func updateFrame(in item: LPPageBarItem) {
        switch style {
        case .stripe(let stripe, _):
            if case .textWidth(let rect) = stripe {
                let width = item.titleLabel.frame.width + rect.lrSpacing * 2.0
                let y = item.frame.height - rect.height - rect.bottom
                frame = CGRect(x: 0.0, y: y, width: width, height: rect.height)
            } else if case .fullWidth(let rect) = stripe {
                let width = item.frame.width - rect.lrSpacing * 2.0
                let y = item.frame.height - rect.height - rect.bottom
                frame = CGRect(x: 0.0, y: y, width: width, height: rect.height)
            }
        case .box:
            frame.size = item.frame.size
        case .arrow(let rect, _):
            let y = item.frame.height - rect.size.height - rect.bottom
            frame = CGRect(origin: CGPoint(x: 0.0, y: y), size: rect.size)
        case .custom(let view, let rect):
            frame.size = item.frame.size
            
            let y = frame.height - rect.size.height - rect.bottom
            view.frame = CGRect(origin: CGPoint(x: 0.0, y: y), size: rect.size)
            view.center.x = frame.width / 2.0
        }
        center.x = item.center.x
    }
    
    /// 绘制箭头形状的Indicator
    ///
    /// - Parameter rect: 绘制区域
    override func draw(_ rect: CGRect) {
        guard case .arrow(_, let color) = style else { return }
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.width / 2.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.close() // 闭合路径,连线结束后会把起点和终点连起来
        path.lineWidth = 2.0 // 设置描边宽度
        color.set() // 设置填充颜色
        path.fill() // 填充
    }
}
