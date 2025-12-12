//
//  ContentView.swift
//  SwiftUINotifiApp
//
//  Created by rico on 11.12.2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var notifyManager = NotificationManager.shared
    let greenColor: Color =  Color(hex: "00E676")
    
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 25) {
                VStack(spacing: 45) {
                    Image(systemName: "bell.badge.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(notifyManager.permissionGranted ? greenColor : greenColor.opacity(0.2))
                        .padding()
                        .background(greenColor.opacity(0.2))
                        .clipShape(Circle())
                    
                    Text("SwiftUI ile Local ve Remote notification ornegi.")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: notifyManager.permissionGranted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    Text(notifyManager.permissionGranted ? "Bildirim izni aktif" : "izin gerekli")
                        .fontWeight(.medium)
                }
                .font(.callout)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(notifyManager.permissionGranted ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                .foregroundStyle(notifyManager.permissionGranted ? .green : .orange)
                .clipShape(Capsule())
                .animation(.easeInOut, value: notifyManager.permissionGranted)
                
                Spacer()
                
                VStack(spacing: 16) {
                    if !notifyManager.permissionGranted {
                        Button {
                            notifyManager.requestPermission()
                        } label: {
                            HStack {
                                Image(systemName: "hand.wave.fill")
                                Text("Baslamak icin izin Ver")
                                    .font(.system(size: 22))
                                    .fontWeight(.medium)
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(greenColor)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    
                    Button {
                        notifyManager.sendLocalNotification()
                    } label: {
                        HStack {
                            Image(systemName: "timer")
                            Text("5 Sn Sonra Test Bildirimi Gonder")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundStyle(notifyManager.permissionGranted ? greenColor : .gray)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!notifyManager.permissionGranted)
                    
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}


/// Color Ext.
extension Color {
    init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
