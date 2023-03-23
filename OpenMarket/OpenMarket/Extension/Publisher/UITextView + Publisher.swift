//
//  UITextView + Publisher.swift
//  OpenMarket
//
//  Created by seohyeon park on 2023/03/23.
//

import Foundation

import UIKit
import Combine

extension UITextView {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextView }
            .compactMap(\.text)
            .eraseToAnyPublisher()
    }
}
