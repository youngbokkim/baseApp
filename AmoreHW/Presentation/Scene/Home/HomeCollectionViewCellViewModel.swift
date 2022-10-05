//
//  HomeCollectionViewCellViewModel.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/01.
//

import Foundation
import RxSwift
import RxCocoa

enum updateType {
    case select
    case deSelect
}

final class HomeCollectionViewCellViewModel: ImageLoadViewModelBase {
    private let idx: Int
    private let hitInfo: Hit
    private let updateCell: Observable<Int>
    let disposeBag: DisposeBag = DisposeBag()
    
    init(idx: Int, hitInfo: Hit, updateCell: Observable<Int>) {
        self.idx = idx
        self.hitInfo = hitInfo
        self.updateCell = updateCell
    }
    
    var userImgUrl: URL? {
        return URL(string: hitInfo.userImageURL)
    }
    
    var webFormatUrl: URL? {
        return URL(string: hitInfo.webformatURL)
    }
    
    var likes: Int {
        return hitInfo.likes
    }
    
    var comments: Int {
        return hitInfo.comments
    }
    
    var user: String {
        return hitInfo.user
    }
    
    func imageKeyPath(url: URL) -> String {
        return saveKeyPath(rootKey: hitInfo.rootKey(), url: url)
    }
    
    func getIdx() -> Int {
        return idx
    }
    
    func bind(output:PublishRelay<updateType>) {
        updateCell.subscribe(onNext: {[weak self] page in
            if page == self?.idx {
                output.accept(.select)
            } else {
                output.accept(.deSelect)
            }
        }).disposed(by: disposeBag)
    }
}
