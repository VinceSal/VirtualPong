//
//  Device.swift
//  Virtual Ping Pong
//
//  Created by Sergio Aprea on 28/02/23.
//

import SwiftUI
import ParthenoKit


struct DeviceView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Imposta un'immagine come sfondo del contenuto
                VStack {
                    Image("choose")
                        .frame(width: 100, height: 100)
                        .position(x: 200, y: 110)
                    
                    Spacer()
                    NavigationLink(destination: ConnectView()) {
                        Image("BlackPaddle")
                            .frame(width: 100, height: 100)
                            .position(x: 50, y: 50)
                        
                        Image("iPhone")
                            .frame(width: 100, height: 100)
                            .position(x: 15, y: 20)
                        Text("")
                            .foregroundColor(.white)
                            .position(x: -20, y: -200)
                    }
                    .border(Color.red, width: 0) // visualizza i confini della vista
                    .frame(width: 100, height: 500).position(x: 100, y:600)
                    NavigationLink(destination: ConnectView()) {
                        Image("RedPaddle")
                            .position(x: 45, y: 60)
                        Image("watch")
                            .position(x:2, y: 35)
                        HeadText(text: "")
                            .font(.system(size: 1))
                            .foregroundColor(.white)
                            .position(x:-30, y: 66)
                    }
                    .border(Color.red, width: 0)
                    .frame(width: 100, height: 300).position(x: 300, y:250)
                    // visualizza i confini della vista
                }
                .background(
                    Image("BG")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                )
                .padding(.bottom, 30)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}


    
struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceView()
    }
}
