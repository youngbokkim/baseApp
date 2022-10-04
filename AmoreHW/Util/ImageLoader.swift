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
    //Q:NSCache에 대해 설명해 주세요. Dictionary와는 무엇이 다른지도 설명해주세요. key와Type이 AnyObject여만 하는 이유는 무엇인가요?
    /*
     NSCache는 앱의 메모리 일부를 캐싱에 사용하는 클래스 이며
     키,벨류 형태의 가변 컬렉션 입니다.
     스레드 세이프하여 lock를 할 필요 없으며
     NSCache은 자동제거정책의 대상이 되어 앱이 메모리 부족시 사라질수 있습니다.
     AnyObject인 이유는 키를 copy 프로토콜이 채택되어 있지 않은 타입도 키로 사용 가능하도록 하기 위함이고
     NSCache는 리테인 됩니다.
     Dictionary는 NSCache와 다르게 키를 copy 합니다.
     이유는 해당 키를 리테인 할 경우 키가 변경되면 값을 찾을수 없기 때문 입니다.
     */
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
    //Q:싱글톤을 사용한 이유는 무엇인가요? 싱글톤의 장단점에 대해 설명해 주세요.
    /*
     싱글톤은 앱에서 유일한 객체입니다.
     싱글톤은 동일한 객체가 많이 생성되어야 할 경우 사용하면
     리소스 낭비를 줄일수 있는 장점이 있습니다.
     하지만 싱글톤이 너무많은 일을 하거나 하면 다른 객체와 종속성이 크게되어 재활용 및 유연함을 해칠수 있습니다.
     */
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
            //Q:task.resume() 밖에 없음. cancel은 어떻게?
            /*
             실수한 부분인거 같습니다. cancel를 깜박해 버렸네요.
             */
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
