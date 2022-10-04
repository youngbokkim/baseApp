//
//  HitsUseCaseInf.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/26.
//

import RxSwift

protocol HitsUseCaseInf {
    //Q:Error 로 처리 했는데 더 좋은 방법은 없나요 ?? , Error 상속 받아서 Custom Error 로 만들어서 하면 좋을거 같음. Enum 으로.
    /*
     netWork 서비스에서 커스텀 에러로 던져 주고 있습니다.
     */
    func getHitsData(page:Int, count:Int) -> Observable<Result<[Hit],Error>>
}
