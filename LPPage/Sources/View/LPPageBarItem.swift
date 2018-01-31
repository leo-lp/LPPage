//
//  LPPageBarItem.swift
//  LPPage
//
//  Created by lipeng on 2017/11/3.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

public class LPPageBarItem: UIControl {
    var selectedTitleColor: UIColor?
    var normalTitleColor: UIColor?
    
    private(set) var titleLabel: UILabel = UILabel()
    public override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? selectedTitleColor : normalTitleColor
        }
    }
    
    deinit {
        #if DEBUG
            print("LPPageBarItem -> relese memory.")
        #endif
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clear
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .center
        titleLabel.frame = bounds
        addSubview(titleLabel)
    }
}
