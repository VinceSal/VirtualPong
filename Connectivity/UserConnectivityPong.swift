//
//  UserConnectivityPong.swift
//  VirtualPong
//
//  Created by Aniello on 03/03/23.
//


import WatchConnectivity
import Foundation
import Combine

class UserConnectivityPong: NSObject, WCSessionDelegate {
    
    private let session: WCSession
    
    private var modelUpdate: PassthroughSubject<Value, Never>
    init(session: WCSession = .default, modelUpdate:
          PassthroughSubject<Value, Never>) {
         
        self.session = session
        self.modelUpdate = modelUpdate
        super.init()
        self.session.delegate = self
    }
    
    func connect(){
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
        session.activate()
        }
    

    func sendMessage(message: [String: Any]) {
//        print("Invio messaggio")
        session.sendMessage(message, replyHandler: nil){
            error in
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let value = Value(path: message["path"] as! String, value: message["value"]!)
//        print("Ricevo")
        self.modelUpdate.send(value)
        print(message)
        }
    
    
#if os (iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
#endif
    


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WCSession activated with state: \(activationState.rawValue)")
    }
    
}

