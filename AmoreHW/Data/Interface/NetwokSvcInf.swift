//
//  NetwokSvcInf.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/27.
//

import RxSwift

protocol NetwokSvcInf {
    func send<T: Decodable>(request: URLRequest?) -> Observable<Result<T,Error>>
}
