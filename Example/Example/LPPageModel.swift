//
//  LPPageEnum.swift
//  Example
//
//  Created by lipeng on 2017/11/21.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import Foundation

enum LPIndicator {
    case none, textWidth, fullWidth, box, arrow, custom
}
enum LPBar {
    case none, normal, showInNavBar, custom
}
enum LPCover {
    case normal, useSafeArea, indicator(LPIndicator), bar(LPBar)
}
enum LPType {
    case indicator(LPIndicator)
    case bar(LPBar)
    case cover(LPCover)
}

struct LPModel {
    struct LPData {
        var title: String
        var id: LPType
        var ok: Bool
    }
    var title: String
    var data: [LPData]
    
    static var list: [LPModel] {
        return [
            LPModel(title: "● 1.0 滑块 - Indicator",
                    data: [LPModel.LPData(title: "不显示 - None", id: .indicator(.none), ok: true),
                           LPModel.LPData(title: "条形，标题等宽 - TextWidth", id: .indicator(.textWidth), ok: true),
                           LPModel.LPData(title: "条形，宽度填充Item - FullWidth", id: .indicator(.fullWidth), ok: true),
                           LPModel.LPData(title: "矩形，宽高填充Item - Box", id: .indicator(.box), ok: true),
                           LPModel.LPData(title: "箭头，方向朝上 - Arrow", id: .indicator(.arrow), ok: true),
                           LPModel.LPData(title: "定制 - Custom", id: .indicator(.custom), ok: true)]),
            LPModel(title: "● 2.0 标签栏 - PageBar",
                    data: [LPModel.LPData(title: "不显示 - None", id: .bar(.none), ok: true),
                           LPModel.LPData(title: "默认 - Normal", id: .bar(.normal), ok: true),
                           LPModel.LPData(title: "显示在导航栏 - ShowInNavBar", id: .bar(.showInNavBar), ok: true),
                           LPModel.LPData(title: "定制PageBar - Custom", id: .bar(.custom), ok: true)]),
            LPModel(title: "● 3.0 封面 - Cover",
                    data: [LPModel.LPData(title: "默认 - Normal", id: .cover(.normal), ok: true),
                           LPModel.LPData(title: "使用安全区域 - UseSafeArea", id: .cover(.useSafeArea), ok: false)]),
            LPModel(title: "● 3.1 封面 - 滑块 - Indicator",
                    data: [LPModel.LPData(title: "不显示 - None", id: .cover(.indicator(.none)), ok: false),
                           LPModel.LPData(title: "条形，标题等宽 - TextWidth", id: .cover(.indicator(.textWidth)), ok: false),
                           LPModel.LPData(title: "条形，宽度填充Item - FullWidth", id: .cover(.indicator(.fullWidth)), ok: false),
                           LPModel.LPData(title: "矩形，宽高填充Item - Box", id: .cover(.indicator(.box)), ok: false),
                           LPModel.LPData(title: "箭头，方向朝上 - Arrow", id: .cover(.indicator(.arrow)), ok: false),
                           LPModel.LPData(title: "定制 - Custom", id: .cover(.indicator(.custom)), ok: false)]),
            LPModel(title: "● 3.2 封面 - 标签栏 - PageBar",
                    data: [LPModel.LPData(title: "不显示 - None", id: .cover(.bar(.none)), ok: false),
                           LPModel.LPData(title: "默认 - Normal", id: .cover(.bar(.normal)), ok: false),
                           LPModel.LPData(title: "显示在导航栏 - ShowInNavBar", id: .cover(.bar(.showInNavBar)), ok: false),
                           LPModel.LPData(title: "定制PageBar - Custom", id: .cover(.bar(.custom)), ok: false)])
        ]
    }
}
