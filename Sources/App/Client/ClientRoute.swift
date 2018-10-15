//
//  ClientRoute.swift
//  App
//
//  Created by Jonathan Green on 10/14/18.
//

import Vapor

enum ClientRoute {

    case orders(orders:Orders)
    
    func request() throws -> HTTPRequest {
        var httpReq = HTTPRequest()
        switch self {
       
        case .orders(let orders):
            httpReq = HTTPRequest(method: .POST, url: "https://zerp-shop.herokuapp.com/products/orders")
            httpReq.contentType = .json
            let jsonDecoder = JSONEncoder()
            let data = try jsonDecoder.encode(orders)
            httpReq.body = HTTPBody(data: data)
        return httpReq
            
        }
    }
}
