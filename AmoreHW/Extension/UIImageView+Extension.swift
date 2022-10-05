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
