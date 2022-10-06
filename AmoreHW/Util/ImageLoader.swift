//
//  ImageLoaderError.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/02.
//

import Foundation
import RxSwift

enum ImageLoaderError: Error {
    case failed
}

final class ImageLoader {
    private var cache = NSCache<AnyObject, AnyObject>()
    private static var imageLoader: ImageLoader = {
        let imageLoader = ImageLoader()
        return imageLoader
    }()
    private lazy var filePath: URL? = {
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                .userDomainMask,
                                                             true).first else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }()

    class func shared() -> ImageLoader {
        return imageLoader
    }
    
    func imageFormUrl(url: URL, key:String) -> Observable<Result<UIImage,Error>> {
        if let image = cache.object(forKey: key as AnyObject) as? UIImage {
            return Observable.just(.success(image))
        }else if var filePath = filePath {
            filePath.appendPathComponent(key)
            if FileManager.default.fileExists(atPath: filePath.path),
               let imageData = try? Data(contentsOf: filePath),
               let image = UIImage(data: imageData) {
                return Observable.just(.success(image))
            }
        }
        
        return Observable.create { [weak self] emitter in
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    emitter.onNext(.failure(ImageLoaderError.failed))
                    emitter.onCompleted()
                    return
                }
                
                if let _ = error {
                    emitter.onNext(.failure(ImageLoaderError.failed))
                    emitter.onCompleted()
                    return
                }

                guard let image = UIImage(data: data) else {
                    emitter.onNext(.failure(ImageLoaderError.failed))
                    emitter.onCompleted()
                    return
                }
                
                self?.cache.setObject(image, forKey: key as AnyObject)
  
                if var filePath = self?.filePath {
                    filePath.appendPathComponent(key)
                    if FileManager.default.fileExists(atPath: filePath.path) == false {
                        let dir = filePath.deletingLastPathComponent().path
                        var isExists: ObjCBool = true
                        let exists = FileManager.default.fileExists(atPath: dir, isDirectory: &isExists)
                        if (exists && isExists.boolValue) == false{
                            try! FileManager.default.createDirectory(atPath: dir,
                                                                    withIntermediateDirectories: true, attributes: nil)
                        }
                        FileManager.default.createFile(atPath: filePath.path,
                                                       contents: image.jpegData(compressionQuality: 0.5),
                                                       attributes: nil)
                    }
                }
                emitter.onNext(.success(image))
                emitter.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
