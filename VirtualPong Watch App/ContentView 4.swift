//
//  ContentView.swift
//  Vpong Watch App
//
//  Created by Vincenzo Salzano on 28/02/23.
//

import SwiftUI

struct ContentView: View {
    
    
    @State private var viewModelPong = ViewModelPong()
    @State var partita = false
    
    var body: some View {
        GeometryReader{
            reader in
            ZStack {
                Image("BG")
                    .resizable()
                    .ignoresSafeArea(.all)
                    .frame(height: reader.size.height)
                VStack {
                    Image("log")
                        .resizable()
                        .position(x: 39.5, y: -8)
                        .frame(width: 70, height: 50)
                    
                        .foregroundColor(.white)
                        .padding()
                    Text("In attesa di connessioni..")
                        .sheet(isPresented: $partita, content: {
                            VibrationView()
                        })
                        .onAppear{
                            let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                                if viewModelPong.partita != false {
                                    partita = true
                                }
                            }
                    }
                }
            }
        }
    }
}
