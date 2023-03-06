import SwiftUI
import ParthenoKit

let rosso = "B82F1C"
let bianco = "FFECDD"
let sfondo = "039445"
var paddle = ""

struct ContentView: View {
    @StateObject var viewModelPong = ViewModelPong()
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
                    NavigationLink(destination: DeviceView(viewModelPong: viewModelPong)) {
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
}


    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

