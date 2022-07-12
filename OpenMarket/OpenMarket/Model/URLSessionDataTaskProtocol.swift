//
//  URLSessionTaskDataProtocol.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/12.
//

import Foundation

protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
