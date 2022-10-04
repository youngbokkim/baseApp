//
//  NetwokSvcInf.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/27.
//

import RxSwift

protocol NetwokSvcInf {
    //Q:제네릭에 대해 설명해 주세요. 그리고 제네릭에서 where 사용하는 방법에 대해서 설명해 주세요.
    /*
     제네릭 스위프트의 가장 강력한 기능중 하나이며
     타입을 추상화하여 코드를 작성할수 있게 해줍니다.
     제네릭은 where 절을 사용하여 제약을 줄수 있습니다.
     */
    func send<T: Decodable>(request: URLRequest?) -> Observable<Result<T,Error>>
}
