//
//  NetworkService.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/26.
//

import Foundation
import RxSwift

final class NetworkSvc {
    let BASE_URL = "https://pixabay.com/api"
    let API_KEY = "8439361-5e1e53a0e1b58baa26ab398f7"
    let disposedBag = DisposeBag()
    
    func getHitsData(page:Int, count:Int) {
        let params:[String:Any] = [
            "key":API_KEY,
            "page":page,
            "per_page":count]
//        
//        RxAlamofire.requestData(.get, BASE_URL, parameters:params)
//            .map {$1}
//            .subscribe(onNext: { data in
//                do {
//                    let model: HitsResult = try JSONDecoder().decode(HitsResult.self, from: data ?? Data())
//                    print(model.hits)
//                } catch let error {
//                    print(error)
//                }},
//                       onError: { error in print(error)},
//                       onCompleted: { print("complete")}
//            ).disposed(by: disposedBag)
    }
}
