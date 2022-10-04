//
//  APIRequest.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/27.
//

import Foundation

public enum RequestType: String {
    case get
    case post
}
protocol APIRequest {
    var method: RequestType { get }
    var endPoint: String { get }
    var parameters: [String: String]? { get }
    var header: [String: String]? { get }
    func buildRequest(baseURL: String) -> URLRequest?
}
//Q:buildRequest시 method에 따라 url 구성이 틀려지지 않을까?
/*
 url 구성이 틀려지며 buildRequest에서 컴포넌트 및 쿼리를 사용해서 이슈는 없을 것 으로 판단 됩니다.
 */
extension APIRequest {
    func buildRequest(baseURL: String) -> URLRequest? {
        guard let url = URL(string: baseURL)
        else { return nil }

        //Q:resolvingAgainstBaseURL 옵션에 대해 설명해 주세요.
        /*
         relativeToURL 을 포함할지 하는 옵션입니다.
         false로 할 경우 relativeToURL을 포함하지 않습니다.
         아래 결과는 true는 false든 같다.
         */
        //Q:URLComponents에 대해서 설명해 주세요.
        /*
         URL을 구성하는 구조체 이다.
         URL에 포함되어 있는 한글, 띄어쓰기 등을 자동으로 인코딩하여 관리합니다. 쿼리 파라미터 등은 URLQueryItem 타입의 변수를 하여 별도로 관리합니다.
         */
        //Q:endPoint의 의미에 대해서 설명해 주세요.
        /*
         동일한 URL에서 API가 서버의 여러개의 리소스를 접근하게 해주는것이 endPoint 입니다.
         */
        guard var components = URLComponents(url: url.appendingPathComponent(endPoint),
                                             resolvingAgainstBaseURL: false)
        else { return nil }

        if let params = parameters {
            components.queryItems = params.map {
                URLQueryItem(name: String($0), value: String($1))
            }
        }
        
        guard let comUrl = components.url
        else { return nil }

        var request = URLRequest(url: comUrl)
        request.httpMethod = method.rawValue
        if let head = header, head.isEmpty == false {
            request.allHTTPHeaderFields = header
        }
        return request
    }
}
