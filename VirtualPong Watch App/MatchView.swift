//
//  VibrationView.swift
//  Vpong Watch App
//
//  Created by Vincenzo Salzano on 28/02/23.
//

import SwiftUI
import WatchKit




struct VibrationView: View {
    
    
    
    @State var timeRemaining = 3.0 // inizialmente 4 secondi
    @State var timer: Timer?
    @State var colpo = ""
    @State var colpo1 = -1.0
    @State var colpo2 = -1.0
    @State var colpo3 = -1.0
    @State var x = 0
    
    @State var dritto = false
    @State var rovescio = false

    private var viewModelPong = ViewModelPong()
    @StateObject private var movimento1 = Movimento()
    @StateObject private var movimento2 = Movimento()
    @StateObject private var movimento3 = Movimento()

    
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
                        .onAppear{
                                if viewModelPong.colpito == false {
                                
                                    movimento1.startMotionUpdates()
                                    usleep(200000)
                                    movimento2.startMotionUpdates()
                                    usleep(200000)
                                    movimento3.startMotionUpdates()
                                    
                                    
                                    
                            }
                            
                    }
                        .onReceive(movimento1.$currentActivity, perform: { value in
                            if value == "dritti" {
                                colpo1 = 0.0
                            } else {
                                colpo1 = 1.0
                            }
                            x = x+1
                        })
                        .onReceive(movimento2.$currentActivity, perform: { value in
                            if value == "dritti" {
                                colpo2 = 0.0
                            } else {
                                colpo2 = 1.0
                            }
                            x = x+1
                        })
                        .onReceive(movimento3.$currentActivity, perform: { value in
                            if value == "dritti" {
                                colpo3 = 0.0
                            } else {
                                colpo3 = 1.0
                            }

                            x = x+1
                            if x == 3 {
                                let c = (colpo1 + colpo2 + colpo3 ) / 3
                                if c > 1.5 {
                                    colpo = "rovescio"
                                } else {
                                    colpo = "dritto"
                                }
                            }
                        })

                }
            }
        }
    }
    
    func startTimer() {
        self.timeRemaining = 3.0 // resetta il tempo rimanente
        self.timer?.invalidate() // invalida eventuali timer già in esecuzione
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.timeRemaining -= 1
            if self.timeRemaining == 1 {
                WKInterfaceDevice.current().play(.failure) // vibrazione quando il timer arriva a 1 secondo dalla scadenza
            } else if self.timeRemaining == 0 {
                WKInterfaceDevice.current().play(.success) // vibrazione alla scadenza del timer
                self.timer?.invalidate() // ferma il timer
            }
        }
    }
    
    func checkColpoForte() {
        if self.timeRemaining >= 1 && self.timeRemaining <= 2 {
            self.timeRemaining = 2 // riduce il tempo rimanente a 3 secondi
        } else {
            self.timeRemaining = 3 // resetta il tempo rimanente a 4 secondi
        }
        if self.rovescio {
            WKInterfaceDevice.current().play(.stop) // vibrazione quando si preme il bottone "rovescio"
            self.rovescio = false // resetta la variabile rovescio
        } else if self.dritto {
            WKInterfaceDevice.current().play(.directionUp) // vibrazione quando si preme il bottone "dritto"
            WKInterfaceDevice.current().play(.directionUp) // vibrazione quando si preme il bottone "dritto"
            self.dritto = false // resetta la variabile dritto
        }
    }
}
