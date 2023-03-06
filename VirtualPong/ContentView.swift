import SwiftUI
import ParthenoKit
import AVFoundation

let rosso = "B82F1C"
let bianco = "FFECDD"
let sfondo = "039445"
var paddle = ""

struct ContentView: View {
    @StateObject var viewModelPong = ViewModelPong()
    @State var prova = false
    var body: some View {
        NavigationView {
            ZStack {
                // Imposta un'immagine come sfondo del contenuto
                Image("bg01")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
             
                    Spacer()
                    Image("log")
                        .position(x:130,y:500)

                
                VStack {
                    Spacer()
                    NavigationLink("", destination: ConnectView(viewModelPong: viewModelPong), isActive: $prova)
                    RoundedButton2(name: "Prova", isActive: $prova)
                    NavigationLink(destination: ConnectView(viewModelPong: viewModelPong)) {
                        RoundedButton(name: "Connect")

                    }
                    NavigationLink (destination: TrainingView(viewModelPong: viewModelPong)) {
                        RoundedButton(name: "Training")
                    }

                }
                .padding(.bottom, 30)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    func playSound(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type, inDirectory: "Suoni") {
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


    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

