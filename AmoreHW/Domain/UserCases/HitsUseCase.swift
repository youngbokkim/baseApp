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
    
    func getHitsData(page: Int, count: Int) -> Observable<Result<[Hit],Error>> {
        let request = SearchRequest(endPoint: endPoint, header: makeSearchHeader()
                                    ,parameters: makeSearchParams(page: page, count: count))
        
        return networkRepository.getHitsData(request: request)
            .map { result -> Result<[Hit],Error> in
                switch result {
                case .success(let res):
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
    
    func testMockData() -> [Hit] {
         guard let path = Bundle.main.path(forResource: "mock", ofType: "json") else {
             return []
         }
         guard let jsonString = try? String(contentsOfFile: path) else {
             return []
         }
         let decoder = JSONDecoder()
         let data = jsonString.data(using: .utf8)
         if let data = data,
            let hitRes = try? decoder.decode(HitsResult.self, from: data) {
              return hitRes.hits
         }
        return []
    }
}
