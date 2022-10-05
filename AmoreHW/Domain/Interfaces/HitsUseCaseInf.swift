//
//  HitsUseCaseInf.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/26.
//

import RxSwift

protocol HitsUseCaseInf {
    func getHitsData(page:Int, count:Int) -> Observable<Result<[Hit],Error>>
}
