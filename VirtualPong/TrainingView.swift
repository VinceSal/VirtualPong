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
    
    let motionManager = CMMotionManager()
    
    let queue = OperationQueue()
    
    private var viewModelPong = ViewModelPong()
    
    @State private var roll = Double.zero
    @State private var z = Double.zero
    @State private var radice = Double.zero
    @State private var turn = true
    @State private var colpito = false
    @State private var punt = 0
    @State private var maxTime = 4.0
    @State private var molt = 1.0
    @State var isRun = false
    @State var direzione = "destra"
    @State var record = 0
    @State var potenza = "lento"
    @State private var colpo = ""
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timer2 = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                    
                    if maxTime == 1 && turn {
                        self.turn = false
                        playSound(sound: "mancato", type: "mp3")
                    }
                    
                    if maxTime > 0 {
                        turn = true
                        maxTime -= 1
                    }
                    
                }
                .onReceive(timer2) {
                    time in
                    colpito = false
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
        .onAppear {
            if !isRun  {
                radice = 0
                //Fa partire il timer solo se non è già attivo
                startTimer()
                isRun = true
                //segnala al watch che deve iniziare a rilevare i movimenti
                viewModelPong.sendMessage(key: "colpito", value: false)
                viewModelPong.colpito = false
                
            } else if isRun {
                //Se colpiamo prima dei 3 secondi avremo un buon colpo e non cambierà il moltiplicatore del tempo
                if maxTime > 0 && radice > 1.3 {
                    isRun = false
                    potenza = "forte"
                    maxTime = 2
                    
                    punt += 1
                    
                } else if maxTime > 0 && radice > 1.1 {
                    isRun = false
                    
                    potenza = "lento"
                    maxTime = 4
                    punt += 1
                }
                //Se finisce il tempo e colpiamo dopo lo 0 avremo mancato il colpo
                else if maxTime == 0 {
                    isRun = false
                    
                    radice = 0
                    colpo = "mancato"
                    maxTime = 4
                    stopTimer()
                    if punt > record {
                        record = punt
                        sleep(1)
                        playSound(sound: "finePartita", type: "mp3")
                        
                    }
                    //                        else {
                    //                            playSound(sound: "lose", type: "mp3")
                    //                        }
                    punt = 0
                    sleep(4)
                    startTimer()
                    
                    
                }
            }
            //Se colpiamo nell'intervallo 0...3 avremo quasi mancato il colpo dunque avremo meno tempo per colpire
            //o il nostro avversario avrà più tempo
            
            
            
            //Aggiorna su parthenokit il risultato del colpo effettuato
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
    
    func tempoBattuta() {
        
        if !isRun {
            isRun = true
            attendiColpo()
        }
        
    }
    
    func attendiColpo (){
        
        
        //Legge il valore di colpo salvato su parthenokit, questo definirà il tempo che avremo a disposizione
        //Se il colpo è stato buono il tempo sarà massimo
        if !isRun {
            if potenza == "forte" {
                self.molt = 0.75
                
                //Se il colpo è stato lento avremo meno tempo per colpire (training) o daremo un bonus al nostro avversario (multi)
            }else {
                self.molt = 1
                //Se il colpo è stato mancato aggiorneremo il risultato e si setterà il moltiplicatore di default
            }
            
            //Fa partire il timer solo se non è già attivo
            startTimer()
            isRun = true
            self.maxTime = 4*molt
            attendiColpo()
        } else if isRun {
            //possibile variabile di stato da comunicare al watch
            //segnala al watch che deve iniziare a rilevare i movimenti
            viewModelPong.sendMessage(key: "colpito", value: false)
            viewModelPong.colpito = false
            //            Vecchio sistema di riconoscimento colpo
            //            da sincronizzare con l'on receive
        }
    }
    
    
    
    
    
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
