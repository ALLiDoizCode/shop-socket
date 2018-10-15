//
//  AnchorMemo.swift
//  App
//
//  Created by Jonathan Green on 10/14/18.
//

import Vapor

struct AnchorMemo:Content {
    var txNumber:String
    var txAmount:Int
    var value:Float
    var conversion:String
    var metaData:String
    var invoiceID:String
}
