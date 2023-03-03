//
//  SwiftUIView.swift
//  Virtual Ping Pong
//
//  Created by Crescenzo Esposito on 31/10/22.
//

import CoreMotion
import AVFoundation
import SwiftUI


struct TrainingView: View {
//Bottone per tornare indietro tra le view personalizzato
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
    }) {
        HStack {
            
            Image(systemName:"arrowshape.turn.up.backward.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: rosso))
        }
    }
    }
    
    
    
    private var viewModelPong = ViewModelPong()
    
    @State private var punt = 0
    @State private var maxTime = 4.0
    let time = 4.0
    @State private var molt = 1.0
    @State var isRun = false
    @State var record = 0
    @State var potenza = "lento"
    @State private var start = false
    @State private var colpo = "battuta"
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView{
            ZStack {
                Color(hex: "039445").ignoresSafeArea(.all)
                Image("BlackPaddle")
                    .aspectRatio(contentMode: .fit)
                VStack {
                    Text("Time: \(maxTime)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.75))
                        .clipShape(Capsule())
                        .onReceive(viewModelPong.$colpito, perform: {
                            value in
                            if value {
                                print("Ricevo colpito dal watch a tempo \(maxTime)")
                                if maxTime > (time/2)-1 && maxTime < (time/2)+1  {
                                    isRun = false
                                    potenza = "forte"
                                    colpo = viewModelPong.colpo
                                    maxTime = 3
                                    
                                    punt += 1
                                    ricevi()
                                    
                                } else if maxTime > 0  {
                                    isRun = false
                                    potenza = "lento"
                                    colpo = viewModelPong.colpo
                                    maxTime = 4
                                    punt += 1
                                    ricevi()
                                }
                                //Se finisce il tempo e colpiamo dopo lo 0 avremo mancato il colpo
                                else if maxTime == 0 {
                                    isRun = false
                                    print("tempo finito")
                                    colpo = "battuta"
                                    maxTime = 4
                                    if punt > record {
                                        record = punt
                                        playSound(sound: "finePartita", type: "mp3")
                                        
                                    }
                                    else {
                                        playSound(sound: "lose", type: "mp3")
                                    }
                                    punt = 0
                                    ricevi()
                                }
                            }
                        })
                    
                    if colpo != "" {
                        HeadText(text: (colpo.capitalized+"!"))
                    }
                    
                    Spacer()
                    
                    
                    Scoreboard(player1: "Punti", player2: "Record", score1: punt, score2: record)
                }
                .onReceive(timer) {
                    //Azione del timer, decrementa il tempo ogni secondo
                    time in
                    if maxTime > 0 && start{
                        maxTime -= 1
                    }
                    
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
        .onAppear {
            viewModelPong.sendMessage(key: "partita", value: true)
            ricevi()
            
            //Se colpiamo nell'intervallo 0...3 avremo quasi mancato il colpo dunque avremo meno tempo per colpire
            //o il nostro avversario avrà più tempo
            
            
            
            //Aggiorna su parthenokit il risultato del colpo effettuato
        }
        
    }
    func ricevi() {
        
        if !isRun && colpo == "battuta" {
            //Fa partire il timer solo se non è già attivo
            //                startTimer()
            print("Attendo primo colpo")
            isRun = true
            start = false
            //segnala al watch che deve iniziare a rilevare i movimenti
            viewModelPong.sendMessage(key: "colpito", value: false)
            //            print("Segnalo al watch di dover colpire")
            viewModelPong.colpito = false
            
        } else if !isRun {
            viewModelPong.sendMessage(key: "colpito", value: false)
            //            print("Segnalo al watch di dover colpire")
            viewModelPong.colpito = false
//            startTimer()
            start = true
            isRun = true
            
        }
    }
    
    
    
    //    func tempoColpo () {
    //        if !isRun && radice > 1.2 {
    //            //Fa partire il timer solo se non è già attivo
    //            self.startTimer()
    //            isRun = true
    //            self.maxTime = 6*molt
    //        } else if isRun {
    //            //Se colpiamo prima dei 3 secondi avremo un buon colpo e non cambierà il moltiplicatore del tempo
    //            if maxTime > 3*molt && radice > 1.2 {
    //                stopTimer()
    //                print("TEST")
    //                isRun = false
    //                colpo = "buono"
    //                self.molt = 1
    //                punt += 1
    //            }
    //            //Se finisce il tempo e colpiamo dopo lo 0 avremo mancato il colpo
    //            else if maxTime == 0 && radice > 1.2 {
    //                stopTimer()
    //                isRun = false
    //                colpo = "mancato"
    //                turno = 0
    //                self.molt = 1
    //                if punt > record {
    //                    record = punt
    //                }
    //                punt = 0
    //            }
    //            //Se colpiamo nell'intervallo 0...3 avremo quasi mancato il colpo dunque avremo meno tempo per colpire
    //            //o il nostro avversario avrà più tempo
    //            else if maxTime < 3*molt && maxTime > 0 && radice > 1.2 {
    //                stopTimer()
    //                isRun = false
    //                colpo = "quasi mancato"
    //                self.molt = 0.5
    //                punt += 1
    //            }
    //            //Aggiorna su parthenokit il risultato del colpo effettuato
    //        }
    //    }
    
    
    
    //Se chiamata ferma il timer
    func stopTimer() {
        self.timer.upstream.connect().cancel()
    }
    //Se chiamata fa partire il timer
    func startTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    
    
    
    
    func playSound(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
                
                audio2 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audio2.play()
            } catch {
                print("ERROR")
            }
        }
    }
}
