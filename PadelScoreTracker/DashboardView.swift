//
//  DashboardView.swift
//  PadelScoreTracker
//
//  Created by Rohan Das on 16/11/2025.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var matchManager = MatchManager()
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var showingMatchView = false
    @State private var showingHealthSetup = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.65, blue: 0.55), Color(red: 0.15, green: 0.55, blue: 0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Padel")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                            
                            if !healthKitManager.isAuthorized {
                                Button(action: {
                                    showingHealthSetup = true
                                }) {
                                    HStack {
                                        Image(systemName: "heart.circle")
                                        Text("Connect to Health")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.25))
                                    )
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            StatCard(title: "Matches Played", value: "\(matchManager.totalMatchesPlayed)", icon: "tennis.racket")
                            StatCard(title: "Total Games", value: "\(matchManager.totalGamesPlayed)", icon: "number")
                            StatCard(title: "Play Time", value: matchManager.totalPlayTimeFormatted, icon: "clock.fill")
                            StatCard(title: "Avg Duration", value: matchManager.averageMatchDuration, icon: "chart.bar.fill")
                            StatCard(title: "Calories Burned", value: "\(matchManager.totalCaloriesBurned)", icon: "flame.fill")
                            StatCard(title: "Health Sync", value: healthKitManager.isAuthorized ? "On" : "Off", icon: "heart.fill")
                        }
                        .padding(.horizontal)
                        
                        // Start Match Button
                        Button(action: {
                            matchManager.startNewMatch()
                            showingMatchView = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 24))
                                Text("Start New Match")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            .foregroundColor(Color(red: 0.2, green: 0.65, blue: 0.55))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Match History
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Match History")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            if matchManager.matches.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "tennis.racket")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white.opacity(0.5))
                                    Text("No matches yet")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                ForEach(matchManager.matches) { match in
                                    MatchHistoryCard(match: match)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top, 10)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingMatchView) {
            MatchView(matchManager: matchManager, healthKitManager: healthKitManager)
        }
        .sheet(isPresented: $showingHealthSetup) {
            HealthSetupView(healthKitManager: healthKitManager)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.white.opacity(0.9))
            
            Text(value)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
        )
    }
}

// MARK: - Match History Card
struct MatchHistoryCard: View {
    let match: PadelMatch
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(match.teamAGames)")
                        .font(.system(size: 32, weight: .bold))
                    Text("-")
                        .font(.system(size: 24, weight: .medium))
                    Text("\(match.teamBGames)")
                        .font(.system(size: 32, weight: .bold))
                }
                .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    Label(match.durationFormatted, systemImage: "clock")
                    Label("\(Int(match.estimatedCalories)) cal", systemImage: "flame")
                }
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let winner = match.winner {
                    Text(winner)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.25))
                        )
                }
                
                Text(match.startTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.12))
        )
    }
}

#Preview {
    DashboardView()
}
