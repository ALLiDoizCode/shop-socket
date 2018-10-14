//
//  Channel.swift
//  App
//
//  Created by Jonathan Green on 10/14/18.
//

import Vapor

struct Channel:Content {
    var command:String
    var accounts:[String]
    
    init(command:String,accounts:[String]) {
        self.command = command
        self.accounts = accounts
    }
}
