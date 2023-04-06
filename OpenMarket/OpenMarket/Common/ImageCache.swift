//
//  ImageCache.swift
//  OpenMarket
//
//  Created by seohyeon park on 2023/03/28.
//

import Foundation
import UIKit.UIImage
import Combine

final class ImageCache {
    static let shared = ImageCache()
    private init() {}
    
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var cancellable = Set<AnyCancellable>()
    
    private func matchImage(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    private func saveCachedImage(url: URL, image: UIImage) {
        cachedImages.setObject(image, forKey: url as NSURL)
    }
    
    func load(url: URL) -> Future<UIImage, NetworkError> {
        if let image = matchImage(url: url as NSURL) {
            return Future { promise in
                promise(.success(image))
            }
        } else {
            return Future { promise in
                NetworkManager().requestToServer(request: URLRequest(url: url))
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }, receiveValue: { [weak self] imageData in
                        guard let image = UIImage(data: imageData) else {
                            promise(.failure(NetworkError.noneData))
                            return
                        }
                        self?.saveCachedImage(url: url, image: image)

                        promise(.success(image))
                    })
                    .store(in: &self.cancellable)
            }
        }
    }
}
