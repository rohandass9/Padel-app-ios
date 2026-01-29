//
//  HealthSetupView.swift
//  PadelScoreTracker
//
//  Created by Rohan Das on 16/11/2025.
//

import SwiftUI
import HealthKit

struct HealthSetupView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.65, blue: 0.55), Color(red: 0.15, green: 0.55, blue: 0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header Icon
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                            .padding(.top, 30)
                        
                        Text("Connect to Apple Health")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Sync your padel workouts to Apple Health to track your activity and calories burned.")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        // Benefits
                        VStack(alignment: .leading, spacing: 16) {
                            BenefitRow(icon: "figure.run", text: "Auto-log workouts as Tennis/Racquet Sports")
                            BenefitRow(icon: "flame.fill", text: "Track calories burned during matches")
                            BenefitRow(icon: "clock.fill", text: "Record match duration and active time")
                            BenefitRow(icon: "heart.fill", text: "Contribute to daily activity goals")
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                        
                        // Connect Button
                        Button(action: {
                            connectToHealth()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "heart.circle.fill")
                                    Text("Connect to Health")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .foregroundColor(Color(red: 0.2, green: 0.65, blue: 0.55))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                            )
                        }
                        .disabled(isLoading)
                        .padding(.horizontal, 30)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Maybe Later")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func connectToHealth() {
        isLoading = true
        
        Task {
            do {
                try await healthKitManager.requestAuthorization()
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to connect to Health. Please check your settings."
                    showError = true
                }
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 35)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.95))
            
            Spacer()
        }
    }
}

#Preview {
    HealthSetupView(healthKitManager: HealthKitManager())
}
