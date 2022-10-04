//
//  NetworkService.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/27.
//

import RxSwift

enum NetworkError: Error {
    case urlError
    case responseError
    case decodeError
}
//Q:status code가 200밖에 정의되어 있지 않음. status code 범위들의 의미는?
/*
 1xx : 정보전달
 2xx : 성공
 3xx : 리다이렉트
 4xx : 클라이언트 오류
 5xx : 서버오류를 의미 합니다.
 */
enum StatusCode:Int {
    case success = 200
}
final class NetworkService: NetwokSvcInf {
    func send<T: Decodable>(request: URLRequest?) -> Observable<Result<T,Error>> {
        guard let urlRequest = request
        else { return Observable.just(Result<T, Error>.failure(NetworkError.urlError)) }

        //Q:Observable을 return type으로 사용하고 있음. Single도 사용가능한데 사용하지 않은 이유는? 차이점은?
        /*
         Single는 문맥상 정보 전달이 명확한 장점이 있지만
         Observable로 시작해서 Single을 엮게 되면
         Single의 success가 onNext , onComplete를 역할을 하기 때문에
         의도치 않은 오류가 발생 할 수 있어 Observable을 사용하였습니다.
         */
        //Q:URLSession 옵션에 대해 설명해 주세요.
        /*
         default : 기본적인 디스크기반 캐싱을 지원 합니다.(쿠키,캐싱등) URLSessionConfiguration.default
         epemeral : 캐싱을 지원하지 않는 private한 세션을 만들때 사용 합니다.URLSessionConfiguration.ephemeral
         backgroud : backgroud 에서 작업을 지원 합니다.URLSessionConfiguration.background(withIdentifier: <#T##String#>)
         */
        //Q:URLSession dataTask 외 Task에 대해서 설명해 주세요.
        /*
         일반적으로 dataTask의 경우 응답으로 NSData를 받게 됩니다. 클로저로 작업이 빈번한 가벼운 get 메소드에 활용 합니다.
         uploadTask의 경우 백그라운드를 지원하며 post,put등 용량이 큰 파일을 전송할때 사용합니다.
         downloadTask의 경우 백그라운드를 지원하며 file형태로 데이터를 받습니다.
         URLSession(configuration: <#T##URLSessionConfiguration#>, delegate: <#T##URLSessionDelegate?#>, delegateQueue: <#T##OperationQueue?#>)
         만들어서 사용할 경우 캐시정책 및 데리게이트를 설정할수 있습니다.
         한번 만들어진 세션을 <#T##URLSessionConfiguration#> 복사해서 사용하므로 이후 변경해도 적용이 되지 않습니다.
         */

        return Observable<Result<T,Error>>.create { emitter in
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    emitter.onNext(.failure(NetworkError.responseError))
                    emitter.onCompleted()
                    return
                }
                if httpResponse.statusCode == StatusCode.success.rawValue {
                    do {
                        //Q:Self , self , Type에 대해 설명해 주세요 T.Type == T.self
                        /*
                         Self는 타입을 채택한 타입을 의미합니다.
                         self는 인스턴스 자체를 의미하고
                         타입의 self는 메타타입의 벨류를 의미 합니다.
                         T.Type을 받는 경우 T.self로 넘겨 주면 됩니다.
                         */
                        let model: T = try JSONDecoder().decode(T.self, from: data ?? Data())
                        emitter.onNext(.success(model))
                    } catch {
                        emitter.onNext(.failure(NetworkError.decodeError))
                    }
                    emitter.onCompleted()
                } else {
                    emitter.onNext(.failure(NetworkError.responseError))
                    emitter.onCompleted()
                    return
                }
            }
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }.share(replay: 1, scope: .forever)
    }
}
