//
//  ViewModelBase.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/28.
//

import RxSwift

protocol ViewModelBase {
    associatedtype Input
    associatedtype Output
    var disposeBag: DisposeBag { get }
    func transform(input: Input) -> Output
}

protocol ImageLoadViewModelBase {
    func saveKeyPath(rootKey: String, url: URL) -> String
}

extension ImageLoadViewModelBase {
    func saveKeyPath(rootKey: String, url: URL) -> String {
        let subPath = url.pathComponents
            .filter{ $0.contains("-") }
            .sorted(by: { $0.count > $1.count })
            .first
        
        if var path = subPath {
            path = path + ".jpg"
            return rootKey + path
        }
        return rootKey + url.lastPathComponent
    }
}
