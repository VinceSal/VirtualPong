//
//  VibrationView.swift
//  Vpong Watch App
//
//  Created by Vincenzo Salzano on 28/02/23.
//

import SwiftUI
import WatchKit
import AVFoundation

var audio = AVAudioPlayer()


struct MatchView: View {
    
    //DA AGGIUNGERE HEALT KIT PER IL BACKGROUND
    
    @State var timeRemaining = 3.0 // inizialmente 4 secondi
    @State var timer: Timer?
    @State var run = false
    @State var colpo = "standing"
    @State var colpo1 = -1.0
    @State var colpo2 = -1.0
    @State var colpo3 = -1.0
    @State var x = 0
    
    
    let queue = DispatchQueue(label: "com.example.predictionQueue", qos: .userInteractive, attributes: .concurrent)
    let delay: TimeInterval = 0.3
    
    // Richiamo startMotionUpdates sulle tre classi movimento diverse
    @StateObject var movimento1 = Movimento()
    @StateObject var movimento2 = Movimento()
    @StateObject var movimento3 = Movimento()
    
    // Eseguo le predizioni in sequenza con uno scostamento di 0,3 secondi
    
    
    
    @State var dritto = false
    @State var rovescio = false
    
    @ObservedObject var viewModelPong: ViewModelPong
    //    @StateObject private var movimento1 = Movimento()
    //    @StateObject private var movimento2 = Movimento()
    //    @StateObject private var movimento3 = Movimento()
    
    
    
    var body: some View {
        GeometryReader{
            reader in
            ZStack {
                Image("BG")
                    .resizable()
                    .ignoresSafeArea(.all)
                    .frame(height: reader.size.height)
                VStack {
                    Text("\(timeRemaining)") // visualizza il tempo rimanente
                        .onReceive(viewModelPong.$colpito, perform: {
                            value in
                            if !value {
                                print("Colpito = \(viewModelPong.colpito)")
                                print("MOVIMENTO")
                                //                                queue.async {
                                if !run {
                                    run = true
                                    movimento3.startMotionUpdates()
                                }
                            }
                            // Esegui la prima predizione
                            //                                                        }
                            //                                                        queue.asyncAfter(deadline: .now() + delay) {
                            //                                                            movimento2.startMotionUpdates()
                            //                                                            // Esegui la seconda predizione
                            //                                                        }
                            //                                                        queue.asyncAfter(deadline: .now() + (2 * delay)) {
                            //                                                            movimento3.startMotionUpdates()
                            //                                                            // Esegui la terza predizione
                            //                                                        }
                            
                            
                            
                        })
//                    Button("Gioca", action: {
//                        viewModelPong.sendMessage(key: "colpo", value: "rovescio")
//                        viewModelPong.sendMessage(key: "colpito", value: true)
//                    })
//
                    //                    }
                    //                                            .onReceive(movimento1.$currentActivity, perform: { value in
                    //                                                if value == "" {
                    //                                                    return
                    //                                                }else if value == "dritti" {
                    //                                                    colpo1 = 0.0
                    //                                                } else {
                    //                                                    colpo1 = 1.0
                    //                                                }
                    //                                                x = x+1
                    //                                                print("Incremento la x la prima volta \(x) \n Il colpo1 era \(colpo1)")
                    //                                            })
                    //                                            .onReceive(movimento2.$currentActivity, perform: { value in
                    //                                                if value == "" {
                    //                                                    return
                    //                                                }else if value == "dritti" {
                    //                                                    colpo2 = 0.0
                    //                                                } else {
                    //                                                    colpo2 = 1.0
                    //                                                }
                    //                                                x = x+1
                    //                                                print("Incremento la x la seconda volta \(x) \n Il colpo2 era \(colpo2)")
                    //
                    //                                            })
                    .onReceive(movimento3.$currentActivity, perform: { value in
                        if value == "dritti" {
                            colpo3 = 0.0
                        } else {
                            colpo3 = 1.0
                        }
                        if x < 3 {
                            x = x+1
                        }
                        print("Incremento la x la terza volta \(x) \n Il colpo3 era \(colpo3)")
                        
                        if x == 1 {
                            //                                                    let c = (colpo1 + colpo2 + colpo3 ) / 3
                            //                                                    if c > 1.5 {
                            //                                                        colpo = "rovescio"
                            //                                                    } else {
                            //                                                        colpo = "dritto"
                            //                                                    }
                            if colpo3 == 0.0 {
                                colpo = "dritto"
                                playSound(sound: "dritto", type: "mp3")
                            } else {
                                colpo = "rovescio"
                                playSound(sound: "rovescio", type: "mp3")
                            }
                            print("CIAO")
                            
                            viewModelPong.sendMessage(key: "colpo", value: colpo)
                            viewModelPong.sendMessage(key: "colpito", value: true)
                            viewModelPong.colpito = true
                            movimento3.stopMotionUpdates()
                            run = false
//                            playSound(sound: "lento", type: "wav")
                            x = 0
                        }
                    })
                    
                }
            }
        }
    }
    
    func playSound(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type, inDirectory: "Suoni") {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
                
                audio = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audio.play()
            } catch {
                print("ERROR")
            }
        }
    }
}
//
//}

    
//    func startTimer() {
//        self.timeRemaining = 3.0 // resetta il tempo rimanente
//        self.timer?.invalidate() // invalida eventuali timer già in esecuzione
//        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            self.timeRemaining -= 1
//            if self.timeRemaining == 1 {
//                WKInterfaceDevice.current().play(.failure) // vibrazione quando il timer arriva a 1 secondo dalla scadenza
//            } else if self.timeRemaining == 0 {
//                WKInterfaceDevice.current().play(.success) // vibrazione alla scadenza del timer
//                self.timer?.invalidate() // ferma il timer
//            }
//        }
//    }
//
//    func checkColpoForte() {
//        if self.timeRemaining >= 1 && self.timeRemaining <= 2 {
//            self.timeRemaining = 2 // riduce il tempo rimanente a 3 secondi
//        } else {
//            self.timeRemaining = 3 // resetta il tempo rimanente a 4 secondi
//        }
//        if self.rovescio {
//            WKInterfaceDevice.current().play(.stop) // vibrazione quando si preme il bottone "rovescio"
//            self.rovescio = false // resetta la variabile rovescio
//        } else if self.dritto {
//            WKInterfaceDevice.current().play(.directionUp) // vibrazione quando si preme il bottone "dritto"
//            WKInterfaceDevice.current().play(.directionUp) // vibrazione quando si preme il bottone "dritto"
//            self.dritto = false // resetta la variabile dritto
//        }
//    }
//}


/*
 
 IPHONE
 2023-03-06 15:32:56.645431+0100 VirtualPong[592:42505] [SceneConfiguration] Info.plist contained no UIScene configuration dictionary (looking for configuration named "(no name)")
 2023-03-06 15:32:56.645509+0100 VirtualPong[592:42505] [SceneConfiguration] Info.plist contained no UIScene configuration dictionary (looking for configuration named "(no name)")
 2023-03-06 15:32:56.645578+0100 VirtualPong[592:42505] [SceneConfiguration] Info.plist contained no UIScene configuration dictionary (looking for configuration named "(no name)")
 sono connesso, ricevo update
 WCSession activated with state: 2
 richiamo send message e mando  ["path": "partita", "value": true]
 Attendo primo colpo
 richiamo send message e mando  ["path": "colpito", "value": false]
 ["value": dritto, "path": colpo]
 ["path": colpito, "value": 1]
 Leggo colpito, nuovo valore: true
 Ricevo colpito dal watch a tempo 4.0
 richiamo send message e mando  ["path": "colpito", "value": false]

 WATCH
 
 2023-03-06 15:32:53.257877+0100 VirtualPong Watch App[423:26147] [SceneConfiguration] Info.plist contained no UIScene configuration dictionary (looking for configuration named "(no name)")
 2023-03-06 15:32:53.258704+0100 VirtualPong Watch App[423:26147] [SceneConfiguration] Info.plist contained no UIScene configuration dictionary (looking for configuration named "(no name)")
 2023-03-06 15:32:53.258852+0100 VirtualPong Watch App[423:26147] [SceneConfiguration] Info.plist contained no UIScene configuration dictionary (looking for configuration named "Default Configuration")
 sono connesso, ricevo update
 WCSession activated with state: 2
 2023-03-06 15:32:54.348676+0100 VirtualPong Watch App[423:26147] [scenes] unable to send desiredFidelity:Never response to desiredFidelityAction:<BLSDesiredFidelityAction: 0x14593220; info: 0x0; responder: <_BSActionResponder: 0x14599e30; active: YES; waiting: NO> clientInvalidated = NO;
 clientEncoded = NO;
 clientResponded = NO;
 reply = <BSMachPortSendOnceRight: 0x14593240; usable: NO; (423:0:send-once xpcCode) from (32:0:send-once take)>;
 annulled = YES;>
 ["path": partita, "value": 1]
 2023-03-06 15:33:08.462506+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:08.463938+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:08.465490+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:08.481054+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:08.482331+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:08.483889+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:08.495496+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:08.496823+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:08.498306+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:08.505118+0100 VirtualPong Watch App[423:26147] [WC] already in progress or activated
 sono connesso, ricevo update
 Leggo colpito, nuovo valore: false
 Colpito = true
 MOVIMENTO
 Start motion
 ["value": 0, "path": colpito]
 2023-03-06 15:33:09.094492+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:09.095728+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:09.097220+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:09.108215+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:09.109504+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:09.110981+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:09.121960+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:09.123356+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:09.124986+0100 VirtualPong Watch App[423:26147] sx and sy should match if stride is not [1,2,3,4,8]
 2023-03-06 15:33:09.131319+0100 VirtualPong Watch App[423:26147] [WC] already in progress or activated
 sono connesso, ricevo update
 Start motion
 Start motion
 Start motion
 Start motion
 Start motion
 Prediction effettuata
 Incremento la x la terza volta 1
  Il colpo3 era 0.0
 CIAO
 richiamo send message e mando  ["path": "colpo", "value": "dritto"]
 richiamo send message e mando  ["value": true, "path": "colpito"]
 dritti
 ["dritti": 0.9521540999412537, "rovesci": 0.047845933586359024, "standing": 3.457227037984012e-08]
 ["path": colpito, "value": 0]
 Leggo colpito, nuovo valore: false

 
 
 
 */
