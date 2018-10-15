//
//  SocketController.swift
//  App
//
//  Created by Jonathan Green on 10/14/18.
//

import Vapor
import Crypto

class SocketController {
    var invoiceID = "4AAC45B7A04109BFF780AD8D97F3D24D848206EE6BC476CCD7A5298953BC959C"
    let apiClient = APIClient()
    var client:Client
    init(client:Client) {
        self.client = client
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
                    print(text)
                    let data = text.convertToData()
                    do {
                        let engineResult = try jsonDecoder.decode(EngineResult.self, from: data)
                        self.handlPayment(engineResult:engineResult)
                    }catch{
                        print(error)
                    }
                    
                })
            })
            
        }catch {
            
        }
    }
    
    func handlPayment(engineResult:EngineResult) {
        let jsonDecoder = JSONDecoder()
        
        guard engineResult.engine_result == "tesSUCCESS" else{
            return
        }
        
        guard engineResult.transaction.InvoiceID == invoiceID else{
            return
        }
        
        let memos = engineResult.transaction.Memos
        
        guard memos.count > 0 else {
            return
        }
        
        let memo = memos[0]
        let hexData = memo.Memo.MemoData.hexDecodedData()
        let memoString = String(data: hexData, encoding: .utf8)
        print(memoString ?? "")
        print(engineResult.transaction.InvoiceID)
        print(engineResult.engine_result)
        let memoData = (memoString ?? "").convertToData()
        
        do{
            let anchorMemo = try jsonDecoder.decode(AnchorMemo.self, from: memoData)
            makeOrder(price:anchorMemo.value, productId: anchorMemo.metaData, quantity: 1,memo:memoString ?? "")
        }catch {
            
        }
        
        
    }
    
    func makeOrder(price:Float,productId:String,quantity:Int,memo:String) {
        var priceRounded = price.rounded(toPlaces: 2)
        print(priceRounded)
        
        do{
            let digest = try SHA1.hash(memo)
            print(digest.hexEncodedString())
            let products = ProductInfo(price: priceRounded, productId: productId, quantity: quantity)
            let orders = Orders(allowPreOrder: false, orderId: digest.hexEncodedString(), products: [products])
            let resposne = Response(using: client.container)
            
            let response = try apiClient.send(client: client, clientRoute: .orders(orders: orders), container: client.container, response: resposne)
            response.map { object in
                print(object)
            }
        }catch{
            
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

extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
