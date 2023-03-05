import CoreMotion
import CoreML
import HealthKit
import WatchKit
// Creazione dell'oggetto per la gestione dei dati dai sensori
    // let motionManager = CMMotionManager()
    
class Movimento: ObservableObject{
    var motionManager = CMMotionManager()
    

    // Creazione dell'oggetto per la predizione di attività
    // let activityClassifier = try? Pong_Test_2(configuration: MLModelConfiguration())
    let activityClassifier = try? Prova_Pong_4(configuration: MLModelConfiguration())

    // Dichiarazione di un timer globale
    var motionTimer: Timer?
    
    // Dichiarazione dell'array di accelerazioni
    var accelerationArrayX = [Double]()
    var accelerationArrayY = [Double]()
    var accelerationArrayZ = [Double]()
    var gyroArrayX = [Double]()
    var gyroArrayY = [Double]()
    var gyroArrayZ = [Double]()
    var start = false
    let stateIn = try! MLMultiArray(shape: [1, 1, 400], dataType: .double)
    @Published var currentActivity: String = "standing"

    
    func handleMotionUpdate(motion: CMMotionManager?) {
        // Verifica che l'oggetto CMMotionManager sia stato passato correttamente
        guard let motion = motion else {
            // Gestione dell'errore di lettura dei dati dai sensori
            print("Errore motion nil")
            return
        }
        
        // Aggiunta delle accelerazioni all'array
        if accelerationArrayX.count < 6 {
            if let data = motion.accelerometerData {
                let x = data.acceleration.x
                let y = data.acceleration.y
                let z = data.acceleration.z
                
                accelerationArrayX.append(x)
                accelerationArrayY.append(y)
                accelerationArrayZ.append(z)
            } else {
                print("No acc data")
            }
            if let data = motion.deviceMotion {
                let x = data.rotationRate.x
                let y = data.rotationRate.y
                let z = data.rotationRate.z
                
                gyroArrayX.append(x)
                gyroArrayY.append(y)
                gyroArrayZ.append(z)
            }else {
                print("No gyro data")
            }
        }
        else if accelerationArrayX.count == 6 && start  {
            predictActivity(lung:6)
        }
    }
    
    
    // Funzione per avviare il timer di aggiornamento dei sensori
    func startMotionUpdates() {
        print("Start motion")
        for i in 0..<stateIn.count {
            stateIn[i] = 0.0
        }
        
        start = true
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates()
        }
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1 // Intervallo di aggiornamento di 0,1 secondi
            motionManager.startAccelerometerUpdates()
            
            
            // Avvio del timer che esegue la predizione di attività ogni 0,5 secondi
            motionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                self.handleMotionUpdate(motion: self.motionManager )
            }
        }
    }
    
    // Funzione per fermare il timer di aggiornamento dei sensori
    func stopMotionUpdates() {
        if motionManager.isAccelerometerActive {
            motionManager.stopAccelerometerUpdates()
        }
        
        if motionManager.isGyroActive {
            motionManager.stopGyroUpdates()
        }
        
        start = false
        motionTimer?.invalidate()
        
        self.gyroArrayX = []
        self.gyroArrayY = []
        self.gyroArrayZ = []
        self.accelerationArrayX = []
        self.accelerationArrayY = []
        self.accelerationArrayZ = []
    }
    
    // Funzione per eseguire la predizione di attività
    func predictActivity(lung:Int) {
        let model = activityClassifier!
        
        // Controllo della lunghezza dell'array di accelerazioni
        guard accelerationArrayX.count == lung && accelerationArrayY.count == lung && accelerationArrayZ.count == lung && gyroArrayX.count == lung && gyroArrayY.count == lung && gyroArrayZ.count == lung else {
            print("Errore lunghezza vettori!")
            self.accelerationArrayX = []
            self.accelerationArrayY = []
            self.accelerationArrayZ = []
            self.gyroArrayX = []
            self.gyroArrayY = []
            self.gyroArrayZ = []
            startMotionUpdates()
            return
        }
        let accX = avgAcceleration(accelerations: accelerationArrayX)
        let accY = avgAcceleration(accelerations: accelerationArrayY)
        let accZ = avgAcceleration(accelerations: accelerationArrayZ)
        let magnitude = sqrt(pow(accX,2) + pow(accY,2) + pow(accZ,2))
        // print(magnitude)
        
        if  magnitude < 3.5  {
            // print("Movimento troppo lento! Hai colpito la rete!")
            self.accelerationArrayX = []
            self.accelerationArrayY = []
            self.accelerationArrayZ = []
            self.gyroArrayX = []
            self.gyroArrayY = []
            self.gyroArrayZ = []
            startMotionUpdates()
            return
        }
        
        // Preparazione dei dati per la predizione
        let accelerationArrayXFloat = accelerationArrayX.map { Double($0) }
        let accelerationArrayYFloat = accelerationArrayY.map { Double($0) }
        let accelerationArrayZFloat = accelerationArrayZ.map { Double($0) }
        
        let gyroArrayXFloat = gyroArrayX.map { Double($0) }
        let gyroArrayYFloat = gyroArrayY.map { Double($0) }
        let gyroArrayZFloat = gyroArrayZ.map { Double($0) }
        
        let accelerationX = try! MLMultiArray(shape: [6], dataType: .double)
        let accelerationY = try! MLMultiArray(shape: [6], dataType: .double)
        let accelerationZ = try! MLMultiArray(shape: [6], dataType: .double)
        
        let gyroX = try! MLMultiArray(shape: [6], dataType: .double)
        let gyroY = try! MLMultiArray(shape: [6], dataType: .double)
        let gyroZ = try! MLMultiArray(shape: [6], dataType: .double)
        
        
        
        //  print("acc_x , acc_y , acc_z , gyro_x , gyro_y , gyro_z")
        for i in 0..<lung {
            accelerationX[i] = accelerationArrayXFloat[i] as NSNumber
            accelerationY[i] = accelerationArrayYFloat[i] as NSNumber
            accelerationZ[i] = accelerationArrayZFloat[i] as NSNumber
            gyroX[i] = gyroArrayXFloat[i] as NSNumber
            gyroY[i] = gyroArrayYFloat[i] as NSNumber
            gyroZ[i] = gyroArrayZFloat[i] as NSNumber
            // print("\(accelerationX[i]),\(accelerationY[i]),\(accelerationZ[i]),\(gyroX[i]),\(gyroY[i]),\(gyroZ[i])")
        }
        
        
        
        // Esecuzione della predizione
        let prediction = try! model.prediction(acc_x: accelerationX, acc_y: accelerationY, acc_z: accelerationZ,gyro_x: gyroX, gyro_y: gyroY, gyro_z: gyroZ, stateIn: stateIn)
        print("Prediction effettuata")
        WKInterfaceDevice.current().play(.start)
        // Aggiornamento della label con l'attività predetta
        currentActivity = prediction.label
        print(prediction.label)
        print(prediction.labelProbability)
        if currentActivity == "dritti" || currentActivity == "rovesci" {
            // print(accelerationX,accelerationY,accelerationZ,gyroX,gyroY,gyroZ)
            stopMotionUpdates()
            self.gyroArrayX = []
            self.gyroArrayY = []
            self.gyroArrayZ = []
            self.accelerationArrayX = []
            self.accelerationArrayY = []
            self.accelerationArrayZ = []
            return
            
        }
        
        // Svuota i vettori per liberare la memoria
        
        self.gyroArrayX = []
        self.gyroArrayY = []
        self.gyroArrayZ = []
        self.accelerationArrayX = []
        self.accelerationArrayY = []
        self.accelerationArrayZ = []
    }
    
    func avgAcceleration(accelerations: [Double]) -> Double {
        // Calcola la norma dell'accelerazione
        var norm = 0.0
        for acc in accelerations {
            norm += acc * acc
        }
        norm = sqrt(norm)
        return norm
    }
}

