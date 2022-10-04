//
//  HomeDetailViewModel.swift
//  AmoreHW
//
//  Created by N4158 on 2022/10/04.
//

import Foundation

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class HomeDetailViewModel: ViewModelBase, Stepper {
    let title: String
    private var hitInfo: Hit
    let disposeBag: DisposeBag = DisposeBag()
    let steps: PublishRelay<Step> = PublishRelay<Step>()
    
    init(title: String, info: Hit) {
        self.title = title
        self.hitInfo = info
    }
    
    struct Input {

    }
    
    struct Output {
       
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        return output
    }
}
