//
//  SearchViewModel.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/01.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class SearchViewModel: ViewModelBase, Stepper {
    let title: String
    let disposeBag: DisposeBag = DisposeBag()
    let steps: PublishRelay<Step> = PublishRelay<Step>()
    
    init(title:String) {
        self.title = title
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
