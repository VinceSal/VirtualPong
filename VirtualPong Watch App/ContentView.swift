//
//  ContentView.swift
//  Vpong Watch App
//
//  Created by Vincenzo Salzano on 28/02/23.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    let healthStore = HKHealthStore()
    @State var session:HKWorkoutSession?
    @State var builder:HKLiveWorkoutBuilder?
    let allTypes = Set([ HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)! , HKObjectType.quantityType(forIdentifier: .heartRate)!])
    
    let config = HKWorkoutConfiguration()
    init() {
        config.activityType = .tableTennis
        config.locationType = .indoor
    }
    
    
    func requestAuth() {
        healthStore.requestAuthorization(toShare: [HKObjectType.workoutType()], read: allTypes) {
            (success, error) in
            if !success {
                print("Error!")
            }
        }
    }
    
    func stopSession() {
        if let session = session {
            session.stopActivity(with: Date())
            session.end()
            print("MOCCMAMMTTTTTT")
            self.session = nil
            builder!.endCollection(withEnd: Date(), completion: {
                _, error in
            })
        }
            
    }
    

    @StateObject var viewModelPong = ViewModelPong()
    @State var partita = false
    
    var body: some View {
        GeometryReader{
            reader in
            ZStack {
                Image("BG")
                    .resizable()
                    .ignoresSafeArea(.all)
                    .frame(height: reader.size.height)
                    .onAppear{
                        requestAuth()
                    }
                VStack {
                    Image("log")
                        .resizable()
                        .position(x: 39.5, y: -8)
                        .frame(width: 70, height: 50)
                    
                        .foregroundColor(.white)
                        .padding()
                    Text("In attesa di connessioni..")
                        .onReceive(viewModelPong.$partita, perform: {
                            value in
                            if value && !partita{
                                partita = true
                                session = try? HKWorkoutSession.init(healthStore: self.healthStore, configuration: config)
                                if let session = session {
                                    builder = session.associatedWorkoutBuilder()
                                    builder!.dataSource = HKLiveWorkoutDataSource(healthStore: self.healthStore, workoutConfiguration: config)
                                    session.startActivity(with: Date())
                                    builder!.beginCollection(withStart: Date(), completion: {
                                        _, error in
                                    })
                                }
                            } else {
                                partita = false
//                                stopSession()
                            }
                        
                        })
                        .sheet(isPresented: $partita, content: {
                            MatchView(viewModelPong: viewModelPong)
                        })
//                        .onAppear{
//                            let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//                                if viewModelPong.partita != false {
//                                    print("Partita = true")
//                                    partita = true
//                                }
//                            }
                    }
                }
            }
        }
    }

