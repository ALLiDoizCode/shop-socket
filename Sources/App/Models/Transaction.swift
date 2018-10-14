//
//  Transaction.swift
//  App
//
//  Created by Jonathan Green on 10/14/18.
//

import Vapor

struct EngineResult:Content {
    var engine_result:String
    var engine_result_code:Int
    var engine_result_message:String
    var ledger_hash:String
    var ledger_index:Int
    var status:String
    var type:String
    var validated:Bool
    var transaction:Transaction
}

struct Transaction:Content {
    var Account:String
    var Amount:String
    var date:Int
    var Destination:String
    var Fee:String
    var hash:String
    var Sequence:Int
    var SigningPubKey:String
    var TransactionType:String
    var TxnSignature:String
    var Memos:[MemoObject]
}

struct MemoObject:Content {
    var Memo:MemoInfo
    
}

struct MemoInfo:Content {
    var MemoData:String
    var MemoType:String
}

