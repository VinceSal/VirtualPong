//
//  Buttons.swift
//  Virtual Ping Pong
//
//  Created by Crescenzo Esposito on 27/10/22.
//

import Foundation
import SwiftUI



extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}



struct RoundedButton: View {
    var name: String

    var body: some View {
        

            ZStack {
//                RoundedRectangle(cornerRadius: 20)
//                    .frame(width: 172.0, height: 81.0)
//                    .foregroundColor(Color(hex: rosso))
//                    .offset()
//
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 165.0, height: 74.0)
                    .foregroundColor(Color(hex: bianco))
                    .shadow(color: Color(hex: rosso) , radius: 1)
                    .shadow(color: Color(hex: rosso),radius: 1)
                    .shadow(color: Color(hex: rosso),radius: 1)
                    .shadow(color: Color(hex: rosso),radius: 1)
                    .shadow(color: Color(hex: rosso),radius: 1)
                    .shadow(color: Color(hex: rosso),radius: 1)
                   
                Button(name) {
                        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                        feedbackGenerator.prepare()
                        feedbackGenerator.impactOccurred()
                        playSound(sound: "button", type: "mp3")
                    
                }
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(Color(hex: rosso))

            }
        
        
  
        
            
        }
    }

struct OvalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(Color (hex: bianco))
            .cornerRadius(30)
            .shadow(color: Color(hex: rosso), radius: 1)
            .shadow(color: Color(hex: rosso), radius: 1)
            .shadow(color: Color(hex: rosso), radius: 1)
            .shadow(color: Color(hex: rosso), radius: 1)
            .shadow(color: Color(hex: rosso), radius: 1)
            .shadow(color: Color(hex: rosso), radius: 1)
            .frame(width: 300)
    }
}

struct HeadText: View {
    var text = ""
    var body: some View {
        Text(text)
            .font(.system(size: 38, weight: .bold))
            .foregroundColor(Color(hex: bianco))
            .padding(.top, 35.0)
            .shadow(color: Color(hex: rosso),radius: 1)
            .shadow(color: Color(hex: rosso),radius: 1)
            .shadow(color: Color(hex: rosso),radius: 1)
            .shadow(color: Color(hex: rosso),radius: 1)
    }
}

struct LogoText: View {
    var text = ""
    var body: some View {
        Text(text)
            .font(.system(size: 80, weight: .bold))
            .foregroundColor(Color(hex: bianco))
            .padding(.top, 35.0)
            .multilineTextAlignment( .center)
            .shadow(color: Color(hex: rosso),radius: 1)
            .shadow(color: Color(hex: rosso),radius: 1)
            .shadow(color: Color(hex: rosso),radius: 1)
            .shadow(color: Color(hex: rosso),radius: 1)
    }
}

struct Scoreboard: View {
    var player1: String
    var player2: String
    var score1: Int
    var score2: Int
    var body: some View {
        

            ZStack {
//                RoundedRectangle(cornerRadius: 20)
//                    .frame(width: 172.0, height: 81.0)
//                    .foregroundColor(Color(hex: rosso))
//                    .offset()
//
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 300, height: 85.0)
                    .foregroundColor(Color(hex: bianco))
                    .shadow(color: Color(hex: rosso) , radius: 1)
                    .shadow(color: Color(hex: rosso),radius: 1)
                    .shadow(color: Color(hex: rosso),radius: 1)
                    .shadow(color: Color(hex: rosso),radius: 1)
                    .shadow(color: Color(hex: rosso),radius: 1)
                    .shadow(color: Color(hex: rosso),radius: 1)
                VStack {
                    HStack {
                        
                        Text(player1)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color(.black))
                            .padding()
                        Text(player2)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color(hex: rosso))
                            .padding()
                    } .offset(y: 15)
                    HStack {
                        
                        Text("\(score1)")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(Color(.black))
                            .multilineTextAlignment(.center)
                            .padding()
                            .offset(x: -20)
                        Text ("-")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(Color(hex: rosso))
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text("\(score2)")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(Color(hex: rosso))
                            .multilineTextAlignment(.center)
                            .padding()
                            .offset(x: 20)
                    }.offset(y: -20)
                }
                
            }
        
  
        
            
        }
    }
