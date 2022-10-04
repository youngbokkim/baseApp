//
//  Observable+Extension.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/02.
//

import RxSwift
import RxCocoa

extension ObservableType {
    func asDriverComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
}
