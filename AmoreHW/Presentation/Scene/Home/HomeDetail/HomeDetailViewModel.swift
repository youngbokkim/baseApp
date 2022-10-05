//
//  HomeDetailViewModel.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/04.
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
        let viewLoad: Observable<Void>
    }
    
    struct Output {
        let hitInfo: PublishRelay<Hit>
    }
    
    func transform(input: Input) -> Output {
        let hitInfo = PublishRelay<Hit>()
        let output = Output(hitInfo: hitInfo)
        
        input.viewLoad.subscribe { _ in
            output.hitInfo.accept(self.hitInfo)
        }.disposed(by: disposeBag)
        
        return output
    }
    
    var webFormatUrl: URL? {
        return URL(string: hitInfo.webformatURL)
    }
    
    func imageKeyPath(url: URL) -> String {
        return saveKeyPath(rootKey: hitInfo.rootKey(), url: url)
    }
}
