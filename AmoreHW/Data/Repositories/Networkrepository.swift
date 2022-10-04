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
    //Q:NetwokSvcInf 프로토콜을 사용하면서 DI를 하지 않은 이유는?
    /*
     변경이 되지 않을 부분이라고 생각하여 주입을 하지 않았지만
     해당 부분은 DI로 처리하는 것이 이후 테스트 및 재활용 및 확장성 면에서 볼때 더 좋을것 같습니다.
     mock NetworkService를 주입해도 될 테구요
     */
    private let networkSvc: NetwokSvcInf
    private let disposeBag = DisposeBag()
    private let baseURL: String
    
    init(networkSvc: NetwokSvcInf, baseURL: String) {
        self.baseURL = baseURL
        self.networkSvc = networkSvc
    }
    //Q:ConcurrentDispatchQueue 에 대해서 설명하세요 , subscribe(on:  에 대해서 설명하세요. , observe(on 이랑 차이가 뭐가 있을까요 ?
    /*
     subscribe은 옵져버블이 동작할 스켜줄러를 지정하고 위치에상관 없이 적용 됩니다.
     observe은 선언된 아래의 스케줄러를 지정합니다.
     MainScheduler.instance는 메인 스레드에서 동작 시키고
     SerialDispatchQueueScheduler는 SerialDispatchQueue에서 task를 직렬 처리 합니다. 동일한 스레드로 보냄
     ConcurrentDispatchQueueScheduler는 ConcurrentDispatchQueue에서 task를 여러 스레드에 분산하여 동시에 처리 합니다.
     ConcurrentMainScheduler.instance 메인 스레드에서 동시 진행 합니다.
     CurrentThreadScheduler 현재 스레드에서 동작 시킵니다.
     */
    func getHitsData(request: APIRequest) -> Observable<Result<HitsResult,Error>> {
        return networkSvc.send(request: request.buildRequest(baseURL: baseURL))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
    }
}
