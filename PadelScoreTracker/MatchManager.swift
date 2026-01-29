import Foundation
import SwiftUI
import Combine

// MARK: - Match Model
struct PadelMatch: Identifiable, Codable {
    let id: UUID
    var teamAGames: Int
    var teamBGames: Int
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var isComplete: Bool
    var estimatedCalories: Double
    
    init(id: UUID = UUID()) {
        self.id = id
        self.teamAGames = 0
        self.teamBGames = 0
        self.startTime = Date()
        self.endTime = nil
        self.duration = 0
        self.isComplete = false
        self.estimatedCalories = 0
    }
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var totalGames: Int {
        teamAGames + teamBGames
    }
    
    var winner: String? {
        guard isComplete else { return nil }
        if teamAGames > teamBGames {
            return "Team A"
        } else if teamBGames > teamAGames {
            return "Team B"
        } else {
            return "Draw"
        }
    }
}

// MARK: - Match Manager
class MatchManager: ObservableObject {
    @Published var matches: [PadelMatch] = []
    @Published var currentMatch: PadelMatch?
    @Published var isMatchActive = false
    
    private let matchesKey = "savedMatches"
    
    init() {
        loadMatches()
    }
    
    // MARK: - Match Control
    func startNewMatch() {
        let newMatch = PadelMatch()
        currentMatch = newMatch
        isMatchActive = true
    }
    
    func updateCurrentMatch(teamAGames: Int, teamBGames: Int, duration: TimeInterval) {
        guard var match = currentMatch else { return }
        match.teamAGames = teamAGames
        match.teamBGames = teamBGames
        match.duration = duration
        match.estimatedCalories = calculateCalories(duration: duration)
        currentMatch = match
    }
    
    func endMatch() async {
        guard var match = currentMatch else { return }
        match.endTime = Date()
        match.isComplete = true
        
        // Save to history
        matches.insert(match, at: 0)
        saveMatches()
        
        // Reset current match
        await MainActor.run {
            currentMatch = nil
            isMatchActive = false
        }
    }
    
    func deleteMatch(at offsets: IndexSet) {
        matches.remove(atOffsets: offsets)
        saveMatches()
    }
    
    // MARK: - Statistics
    var totalMatchesPlayed: Int {
        matches.count
    }
    
    var totalPlayTime: TimeInterval {
        matches.reduce(0) { $0 + $1.duration }
    }
    
    var totalPlayTimeFormatted: String {
        let hours = Int(totalPlayTime) / 3600
        let minutes = Int(totalPlayTime) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var totalGamesPlayed: Int {
        matches.reduce(0) { $0 + $1.totalGames }
    }
    
    var averageMatchDuration: String {
        guard !matches.isEmpty else { return "0m" }
        let avg = totalPlayTime / Double(matches.count)
        let minutes = Int(avg) / 60
        return "\(minutes)m"
    }
    
    var totalCaloriesBurned: Int {
        Int(matches.reduce(0) { $0 + $1.estimatedCalories })
    }
    
    // MARK: - Persistence
    private func saveMatches() {
        if let encoded = try? JSONEncoder().encode(matches) {
            UserDefaults.standard.set(encoded, forKey: matchesKey)
        }
    }
    
    private func loadMatches() {
        if let data = UserDefaults.standard.data(forKey: matchesKey),
           let decoded = try? JSONDecoder().decode([PadelMatch].self, from: data) {
            matches = decoded
        }
    }
    
    // MARK: - Calorie Calculation
    private func calculateCalories(duration: TimeInterval) -> Double {
        // Approximate: Padel burns about 400-600 calories per hour
        // Using 500 cal/hour as average
        let hours = duration / 3600
        return hours * 500
    }
}
