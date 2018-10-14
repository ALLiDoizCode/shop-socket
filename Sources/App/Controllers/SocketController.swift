//
//  SocketController.swift
//  App
//
//  Created by Jonathan Green on 10/14/18.
//

import Vapor

class SocketController {

    init(client:Client) {
        let channel = Channel(command: "subscribe", accounts: ["rfFXHU7Syn1zN62ooeqWDm12QjuErMA2Tp"])
    
        let jsonEncorder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        do {
            print("setting up socket")
            let data = try jsonEncorder.encode(channel)
        
            _ = try client.webSocket("wss://sbc-rippled.com/ws").map({ ws in
                print("socket ready")
                ws.send(data)
               
                ws.onText({ (ws, text) in
                    let data = text.convertToData()
                    do {
                        /*let dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] ?? [String:AnyObject]()
                        print(dictonary)
                        let transaction = dictonary["transaction"] as? [String:AnyObject] ?? [String:AnyObject]()
                        print(transaction)
                        let memos = transaction["Memos"] as? [[String:AnyObject]] ?? [[String:AnyObject]]()
                        print(memos)
                        for memo in memos {
                            let memoData = memo["MemoData"] as? String
                            print(memoData)
                        }*/
                        let engineResult = try jsonDecoder.decode(EngineResult.self, from: data)
                        print(engineResult.engine_result_message)
                        let hexData = engineResult.transaction.Memos[1].Memo.MemoData.hexDecodedData()
                        let memoString = String(data: hexData, encoding: .utf8)
                        print(memoString ?? "")
                    }catch{
                        print(error)
                    }
                    
                })
            })
            
        }catch {
            
        }
    }
}

extension String {
    /// A data representation of the hexadecimal bytes in this string.
    func hexDecodedData() -> Data {
        // Get the UTF8 characters of this string
        let chars = Array(utf8)
        
        // Keep the bytes in an UInt8 array and later convert it to Data
        var bytes = [UInt8]()
        bytes.reserveCapacity(count / 2)
        
        // It is a lot faster to use a lookup map instead of strtoul
        let map: [UInt8] = [
            0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
            0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
            0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
        ]
        
        // Grab two characters at a time, map them and turn it into a byte
        for i in stride(from: 0, to: count, by: 2) {
            let index1 = Int(chars[i] & 0x1F ^ 0x10)
            let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
            bytes.append(map[index1] << 4 | map[index2])
        }
        
        return Data(bytes)
    }
}
