//
//  Orders.swift
//  App
//
//  Created by Jonathan Green on 10/14/18.
//

import Vapor

struct Orders:Content {
    var allowPreOrder:Bool
    var orderId:String
    var products:[ProductInfo]
    
    init(allowPreOrder:Bool,orderId:String,products:[ProductInfo]) {
        self.allowPreOrder = allowPreOrder
        self.orderId = orderId
        self.products = products
    }
}

struct ProductInfo:Content {
    var price:Float
    var productId:String
    var quantity:Int
    
    init(price:Float,productId:String,quantity:Int) {
        self.price = price
        self.productId = productId
        self.quantity = quantity
    }
}

