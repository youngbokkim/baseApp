//
//  NetworkRepository.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/27.
//

import RxSwift

struct SearchRequest: APIRequest {
    var method = RequestType.get
    var endPoint: String
    var parameters: [String: String]?
    var header: [String: String]?
    init(endPoint: String, header: [String: String]?, parameters: [String: String]?) {
        self.endPoint = endPoint
        self.header = header
        self.parameters = parameters
    }
}

final class NetworkRepository: NetworkRepoInf {
    private let networkSvc: NetwokSvcInf
    private let disposeBag = DisposeBag()
    private let baseURL: String
    
    init(networkSvc: NetwokSvcInf, baseURL: String) {
        self.baseURL = baseURL
        self.networkSvc = networkSvc
    }

    func getHitsData(request: APIRequest) -> Observable<Result<HitsResult,Error>> {
        return networkSvc.send(request: request.buildRequest(baseURL: baseURL))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
    }
}
