//
//  ViewModelPong.swift
//  VirtualPong
//
//  Created by Crescenzo Esposito on 03/03/23.
//

import Foundation
import Combine

struct Value {
    let path: String
    let value: Any
}

class ViewModelPong: ObservableObject {
    private var userConnectivityPong: UserConnectivityPong
    
    var requests: AnyCancellable?
    var valueModelPong: PassthroughSubject<Value, Never> = PassthroughSubject()
    
    @Published var colpo = "Paolo"
    @Published var partita = false
    @Published var player = 0
    @Published var colpito = true
    
    init(){
        userConnectivityPong = UserConnectivityPong(modelUpdate: valueModelPong)
        userConnectivityPong.connect()
        print("sono connesso, ricevo update")
        
        requests = valueModelPong.sink {
            value in
            DispatchQueue.main.async{
                switch value.path {
                case "colpo":
//                    print("Leggo colpo, nuovo valore: \(value.value as! String)")
                    self.colpo = value.value as! String
                case "partita":
//                    print("Leggo partita, nuovo valore: \(value.value as! Bool)")
                    self.partita = value.value as! Bool
                case "player":
                    self.player = value.value as! Int
                case "colpito":
                    self.colpito = value.value as! Bool
                default:
                    print("Error")
                    
                }
                }
            }
        }
    
    func sendMessage(key: String, value: Any){
        let message = ["path": key, "value": value]
//        print("richiamo send message e mando ", message)
        userConnectivityPong.sendMessage(message: message)
    }
}

