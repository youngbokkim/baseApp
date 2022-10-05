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

enum StatusCode:Int {
    case success = 200
}

final class NetworkService: NetwokSvcInf {
    func send<T: Decodable>(request: URLRequest?) -> Observable<Result<T,Error>> {
        guard let urlRequest = request
        else { return Observable.just(Result<T, Error>.failure(NetworkError.urlError)) }

        return Observable<Result<T,Error>>.create { emitter in
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    emitter.onNext(.failure(NetworkError.responseError))
                    emitter.onCompleted()
                    return
                }
                if httpResponse.statusCode == StatusCode.success.rawValue {
                    do {
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
