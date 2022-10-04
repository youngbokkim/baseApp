//
//  HisUseCase.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/26.
//

import Foundation
import RxSwift


let BASE_URL = "https://pixabay.com"
let API_KEY = "8439361-5e1e53a0e1b58baa26ab398f7"

final class HitsUseCase: HitsUseCaseInf {
    private let networkRepository: NetworkRepoInf
    private let endPoint = "api"
    
    init(networkRepository: NetworkRepoInf) {
        self.networkRepository = networkRepository
    }
    //Q:Observable 이랑 single 이랑 차이점에 대해서 설명.
    /*
     single , Maybe , Completed의 경우 문맥상 전달이 명확한 장점이 있습니다.
     single는 onSuccess , OnError
     Maybe는 onSuccess , OnError , 컴플리트
     Completed OnError , 컴플리트를 전달 할 수있습니다.
     다만 single의 onSuccess는 onNext,onCompleted를 의미하므로 Observable랑 엮어서 사용하게 되면
     의도차 않은 오류를 잃으킬수 있습니다.
     */
    //Q:searchKeyword시 Observable<Result<[SearchCellViewModel],Error>> 를 리턴타입으로 정한 이유는?
    /*
     레파지토리에서 받은 데이터를 최종 ViewModel의 형태로 전달 하려고 사용 하였습니다.
     */
    //Q:CellViewModel을 리턴타입으로 하면 SearchUseCase가 CellViewModel을 생성하는데만 사용가능해야 하는가? 확장성 x 재활용성 x
    /*
     부족했던 부분인것 같습니다.
     해당 부분을 이렇게 사용하여 확장성 과 재활용성이 없어 졌습니다.
     다시 하게 된다면 제네릭을 사용할 것 같습니다.
     */
    func getHitsData(page: Int, count: Int) -> Observable<Result<[Hit],Error>> {
        let request = SearchRequest(endPoint: endPoint, header: makeSearchHeader()
                                    ,parameters: makeSearchParams(page: page, count: count))
        
        return networkRepository.getHitsData(request: request)
            .map { result -> Result<[Hit],Error> in
                switch result {
                case .success(let res):
//                    guard let path = Bundle.main.path(forResource: "mock", ofType: "json") else {
//                        return .success(res.hits)
//                    }
//                    guard let jsonString = try? String(contentsOfFile: path) else {
//                        return .success(res.hits)
//                    }
//                    let decoder = JSONDecoder()
//                    let data = jsonString.data(using: .utf8)
//                    if let data = data,
//                       let hitRes = try? decoder.decode(HitsResult.self, from: data) {
//                        return .success(hitRes.hits)
//                    }
                    return .success(res.hits)
                case .failure(let error):
                    return .failure(error)
                }
        }
    }
}
fileprivate extension HitsUseCase {
    func makeSearchHeader() -> [String: String] {
        return ["application/json": "Accept"]
    }
    func makeSearchParams(page: Int, count: Int) -> [String: String] {
        let params:[String:String] = [
            "key":API_KEY,
            "page":"\(page)",
            "per_page":"\(count)"]
        return params
    }
}
