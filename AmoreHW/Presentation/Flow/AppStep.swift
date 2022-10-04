//
//  AppStep.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/28.
//

import RxFlow

enum AppStep: Step {
    case appMain
    case appHome
    case appHomeDetail(info: Hit)
    case appSearch
    case appBeauty
    case appProfile
}
