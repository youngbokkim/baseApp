//
//  NetworkRepoInf.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/26.
//

import RxSwift

protocol NetworkRepoInf {
    func getHitsData(request: APIRequest) -> Observable<Result<HitsResult,Error>>
}
