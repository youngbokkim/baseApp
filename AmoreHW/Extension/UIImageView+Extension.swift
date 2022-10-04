//
//  UIImageView+Extension.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/02.
//

import UIKit
import RxSwift
import RxCocoa

extension UIImageView {
    func setImageUrl(url: URL, key: String) -> Disposable {
        image = nil
        //Q:setImageUrl을 캔슬할 수 있는 방법은? 셀 재활용시 다운로드 취소 불가
        /*
         실수 한 부분인거 같습니다.
         현재는 취소 할 수 있는 방법이 없습니다.
         */
        let image = ImageLoader.shared().imageFormUrl(url: url, key:key)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
            .map { result -> UIImage in
                switch result {
                case .success(let image):
                    return image
                case .failure(_):
                    return UIImage()
                }
            }.asDriverComplete()
        return image.drive(rx.image)
    }
}
