//
//  HostView.swift
//  Virtual Ping Pong
//
//  Created by Crescenzo Esposito on 27/10/22.
//

import SwiftUI
import ParthenoKit
import CoreMotion
import AVFoundation

var audio = AVAudioPlayer()
var audio2 = AVAudioPlayer()

var playerID = 0
var player1 = 0
var player2 = 0

struct MatchView: View {
    
    let motionManager = CMMotionManager()
    @ObservedObject var viewModelPong: ViewModelPong
    let queue = OperationQueue()
    
    @State private var x = 0
    
    
    @State private var colpito = false
    
    @State private var roll = Double.zero
    @State private var z = Double.zero
    @State private var radice = Double.zero
    // var time = 0.0
    //Variabili da sistemare, alcune sono inutili
    @State var molt = 1.0
    @State private var maxTime = 4.0
    @State var isRun = false
    var codeToShare: String
    @State private var turn = true
    @State private var players: Int = 0
    var p = ParthenoKit()
    @State private var colpo = ""
    
    @State private var turno = ""
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var battuta = true
    @State private var forza = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: sfondo).ignoresSafeArea(.all)
                Image("BlackPaddle")
                    .aspectRatio(contentMode: .fit)
                VStack {
                    
                    //TIMER - MOSTRA IL TEMPO DISPONIBILE
                    HeadText(text: "Player \(playerID)")
                    Text("Time: \(maxTime)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.75))
                        .clipShape(Capsule())
                    
                    if players == 1 {
                        //Aggiorna continuamente il valore di players in attesa che qualcuno si connetta
                        HeadText(text: "Waiting for player 2")
                            .onAppear {
                                let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                                    if self.players < 2 {
                                        let res = p.readSync(team: "TeamC92FKSZ", tag: codeToShare, key: "players")
                                        self.players = Int(res["players"]!)!
                                    }
                                }
                            }
                        Spacer()
                        
                    }
                    
                    if players > 2 {
                        HeadText(text: "Sorry, Lobby is full!")
                        Spacer()
                        //Entra in questo blocco solo se ci sono due player connessi
                    }else if players == 2 {
                        //SETTO DEFAULT PER EVITARE CAMPI VUOTI
                        //let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "turno", value: "1")
                        //let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "colpo", value:"buono")
                        //Mostra il risultato del colpo effettuato (di default è def)
                        HeadText(text: "\n Turno: \(turno)\n \(colpo)" )
                            .onAppear{
                                print("invio messaggio connect")
                                viewModelPong.sendMessage(key: "partita", value: true)
                                
                            }
                            .onReceive(viewModelPong.$colpito, perform: { value in
                                if value {
                                    self.stopTimer()
                                    
                                    //Da aggiungere il random
//                                    if colpo == viewModelPong.colpo {
//                                        print("Hai sbagliato colpo errore!")
//                                    } else {
                                        colpo = viewModelPong.colpo
//                                    }
                                    
                                    if maxTime > (maxTime/2)-1 && maxTime < (maxTime/2)+1  {
                                        isRun = false
                                        forza = "forte"
                                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "forza", value:forza)
                                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "colpo", value:colpo)
                                    }else if maxTime == 0  {
                                        playSound(sound: "lose", type: "mp3")
                                        isRun = false
                                        colpo = "battuta"
                                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "colpo", value:colpo)
                                        if playerID == 1 {
                                            player2 += 1
                                            let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "turno", value: "2")
                                            let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "p2", value:"\(player2)")
                                            
                                        } else if playerID == 2{
                                            player1 += 1
                                            let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "turno", value: "1")
                                            let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "p1", value:"\(player1)")
                                        }
                                    }else if maxTime > 0 {
                                        isRun = false
                                        forza = "lento"
                                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "colpo", value:colpo)
                                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "forza", value:forza)
                                    }
                                    print("SET TURNO")
                                    if playerID == 2 {
                                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "turno", value: "1")
                                    } else if playerID == 1 {
                                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "turno", value: "2")
                                    }
                                    
                                }
                            })
                        
                        
                        //                        RoundedButton(name: "Colpo")
                        //                            .onTapGesture {
                        //                                //Chiama la funzione tempoColpo ogni volta che clicchiamo su colpo
                        //                                //Da gestire quando può farlo player 1 e quando player 2
                        //
                        //                                if Int(turno) == playerID {
                        //
                        //                                }
                        //                            }
                        
                        
                        //Risultati
                        Scoreboard(player1: "Player 1", player2: "Player 2", score1: player1, score2: player2)
                    }
                }
            }
            .onReceive(timer) {
                //Azione del timer, decrementa il tempo ogni secondo
                time in
                if maxTime == 0 && isRun && !viewModelPong.colpito {
                    isRun = false
                    colpo = "battuta"
                    let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "colpo", value:colpo)
                    if playerID == 1 {
                        player2 += 1
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "turno", value: "2")
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "p2", value:"\(player2)")
                        
                    } else if playerID == 2{
                        player1 += 1
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "turno", value: "1")
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "p1", value:"\(player1)")
                    }
                    
                }
                if maxTime == 1 && turn {
                    self.turn = false
                    playSound(sound: "mancato", type: "mp3")
                }
                if maxTime > 0 {
                    turn = true
                    maxTime -= 1
                }
            }
        }.navigationBarBackButtonHidden(true)
            .onAppear() {
                //Stop timer perchè sennò partiva in automatico
                
                self.stopTimer()
                let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    
                    
                    let res = p.readSync(team: "TeamC92FKSZ", tag: codeToShare, key: "%")
                    turno = res["turno"]!
                    forza = res["forza"] ?? "lento"
                    colpo = res["colpo"] ?? "battuta"
                    player1 = Int(res["p1"] ?? "0")!
                    player2 = Int(res["p2"] ?? "0")!
                    print("Int turno: \(Int(turno) ?? 0)")
                    if  Int(turno) == playerID  && players == 2{
                        if !isRun && colpo != "battuta"{
                            attendiColpo()
                        } else if !isRun && colpo == "battuta" {
                            tempoBattuta()
                        }
                    }
                }
                
                
                //Appena entriamo nella match view legge il numero di player connessi
                let res = p.readSync(team: "TeamC92FKSZ", tag: codeToShare, key: "players")
                self.players = Int(res["players"]!)!
                //Se ci sono meno di 3 giocatori incrementa il valore dei players e aggiorna il risultato su pk
                if self.players < 3 {
                    players += 1
                    if players == 1 {
                        playerID = 1
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "turno", value: "1")
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "colpo", value:"battuta")
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "forza", value:"lento")
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "p1", value:"0")
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "p2", value:"0")
                    }
                    if players == 2 {
                        playerID = 2
                        //Inizializzatori di default per evitare di leggere valori nil
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "turno", value: "1")
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "colpo", value:"battuta")
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "forza", value:"lento")
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "p1", value:"0")
                        let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "p2", value:"0")
                    }
                    let _ = p.writeSync(team: "TeamC92FKSZ", tag: codeToShare, key: "players", value:"\(players)")
                }
                
                
            }
    }
    
    
    
    //func tempoColpo () {
    
    //}
    func tempoBattuta() {
        
        if !isRun {
            self.molt = 1
            isRun = true
            self.maxTime = 4*molt
            attendiColpo()
        }
        
    }
    func attendiColpo (){
        
        
        //Legge il valore di colpo salvato su parthenokit, questo definirà il tempo che avremo a disposizione
        //Se il colpo è stato buono il tempo sarà massimo
        if !isRun {
            if forza == "forte" {
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
        playSound(sound: "mioturno", type: "mp3")
    }
    
    
    
    
    
    
    
    
    
    //struct MatchView_Previews: PreviewProvider {
    //    static var previews: some View {
    //        MatchView(players: 1 )
    //    }
    //}
    
    
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

