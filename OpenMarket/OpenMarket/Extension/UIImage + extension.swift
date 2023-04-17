//
//  UIImage + extension.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/01.
//

import UIKit

extension UIImage {
    private func resizeImage(image: UIImage,
                             newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth,
                                           height: newHeight))
        image.draw(in: CGRect(x: 0,
                              y: 0,
                              width: newWidth,
                              height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    func compress() -> Data? {
        let quality: CGFloat = 300 / self.sizeAsKilobyte()
        if let resizedImage = resizeImage(image: self,
                                          newWidth: 500),
           let compressedData: Data = resizedImage.jpegData(compressionQuality: quality)
        {
            return compressedData
        }
        return Data()
    }
    
    private func sizeAsKilobyte() -> Double {
        guard let dataSize = self.pngData()?.count else { return 0 }
        
        return Double(dataSize / 1024)
    }
}
