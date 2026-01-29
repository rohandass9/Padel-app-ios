//
//  MatchView.swift
//  PadelScoreTracker
//
//  Created by Rohan Das on 16/11/2025.
//
import SwiftUI

struct MatchView: View {
    @ObservedObject var matchManager: MatchManager
    @ObservedObject var healthKitManager: HealthKitManager
    @Environment(\.dismiss) var dismiss
    
    @State private var teamAGames = 0
    @State private var teamBGames = 0
    @State private var teamAPoints = 0
    @State private var teamBPoints = 0
    @State private var matchTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingEndMatch = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.65, blue: 0.55), Color(red: 0.15, green: 0.55, blue: 0.45)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        showingEndMatch = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Timer
                    Text(timeFormatted)
                        .font(.system(size: 20, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Pause/Resume could go here
                    }) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .opacity(0) // Hidden but maintains spacing
                }
                .padding()
                
                Spacer()
                
                // Game Scores
                HStack(spacing: 40) {
                    VStack(spacing: 4) {
                        Text("Team A")
                            .font(.system(size: 16, weight: .medium))
                        Text("\(teamAGames)")
                            .font(.system(size: 44, weight: .bold))
                    }
                    
                    VStack(spacing: 4) {
                        Text("Team B")
                            .font(.system(size: 16, weight: .medium))
                        Text("\(teamBGames)")
                            .font(.system(size: 44, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .padding(.bottom, 20)
                
                // Point Scores
                HStack(spacing: 8) {
                    // Team A
                    Button(action: {
                        pointWonBy(team: .A)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                            
                            Text(pointDisplay(for: .A))
                                .font(.system(size: 72, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Divider
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 3)
                    
                    // Team B
                    Button(action: {
                        pointWonBy(team: .B)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                            
                            Text(pointDisplay(for: .B))
                                .font(.system(size: 72, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .frame(height: 200)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Undo Button
                Button(action: {
                    undoLastPoint()
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Undo Last Point")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .alert("End Match?", isPresented: $showingEndMatch) {
            Button("Cancel", role: .cancel) { }
            Button("End Match", role: .destructive) {
                Task {
                    await endMatch()
                }
            }
        } message: {
            Text("Final Score: \(teamAGames) - \(teamBGames)\nDuration: \(timeFormatted)")
        }
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            matchTime += 1
            matchManager.updateCurrentMatch(teamAGames: teamAGames, teamBGames: teamBGames, duration: matchTime)
        }
    }
    
    private var timeFormatted: String {
        let hours = Int(matchTime) / 3600
        let minutes = Int(matchTime) / 60 % 60
        let seconds = Int(matchTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    // MARK: - Scoring Logic
    enum Team {
        case A, B
    }
    
    @State private var lastScoringTeam: Team?
    
    func pointDisplay(for team: Team) -> String {
        let points = team == .A ? teamAPoints : teamBPoints
        let opponentPoints = team == .A ? teamBPoints : teamAPoints
        
        // Check for advantage/deuce
        if teamAPoints >= 3 && teamBPoints >= 3 {
            if points > opponentPoints {
                return "AD"
            } else {
                return "40"
            }
        }
        
        // Normal scoring
        switch points {
        case 0: return "0"
        case 1: return "15"
        case 2: return "30"
        case 3: return "40"
        default: return "40"
        }
    }
    
    func pointWonBy(team: Team) {
        lastScoringTeam = team
        
        if team == .A {
            teamAPoints += 1
        } else {
            teamBPoints += 1
        }
        
        checkGameWin()
    }
    
    func checkGameWin() {
        // Win conditions
        if teamAPoints >= 4 && teamAPoints >= teamBPoints + 2 {
            teamAGames += 1
            resetPoints()
        } else if teamBPoints >= 4 && teamBPoints >= teamAPoints + 2 {
            teamBGames += 1
            resetPoints()
        }
    }
    
    func resetPoints() {
        teamAPoints = 0
        teamBPoints = 0
    }
    
    func undoLastPoint() {
        guard let lastTeam = lastScoringTeam else { return }
        
        if lastTeam == .A && teamAPoints > 0 {
            teamAPoints -= 1
        } else if lastTeam == .B && teamBPoints > 0 {
            teamBPoints -= 1
        }
    }
    
    // MARK: - End Match
    func endMatch() async {
        timer?.invalidate()
        
        // Save to HealthKit if authorized
        if healthKitManager.isAuthorized, let match = matchManager.currentMatch {
            do {
                try await healthKitManager.saveWorkout(
                    startDate: match.startTime,
                    endDate: Date(),
                    caloriesBurned: match.estimatedCalories
                )
            } catch {
                print("Failed to save workout: \(error)")
            }
        }
        
        await matchManager.endMatch()
        dismiss()
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    MatchView(
        matchManager: MatchManager(),
        healthKitManager: HealthKitManager()
    )
}
