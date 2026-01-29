import SwiftUI

struct ContentView: View {
    @State private var teamAGames = 0
    @State private var teamBGames = 0
    @State private var teamAPoints = 0
    @State private var teamBPoints = 0
    @State private var isDeuce = false
    @State private var showingReset = false
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.2, green: 0.65, blue: 0.55)
                .ignoresSafeArea()
            
            VStack(spacing: 5) {
                // Game scores at top
                HStack(spacing: 30) {
                    VStack(spacing: 2) {
                        Text("A")
                            .font(.system(size: 16, weight: .semibold))
                        Text("\(teamAGames)")
                            .font(.system(size: 20, weight: .bold))
                    }
                    
                    VStack(spacing: 2) {
                        Text("B")
                            .font(.system(size: 16, weight: .semibold))
                        Text("\(teamBGames)")
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .padding(.top, 8)
                
                // Main score display
                HStack(spacing: 0) {
                    
                    // Team A Score Button
                    Button(action: {
                        pointWonBy(team: .A)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                            
                            Text(pointDisplay(for: .A))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)
                    
                    // Divider
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 3)
                    
                    // Team B Score Button
                    Button(action: {
                        pointWonBy(team: .B)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                            
                            Text(pointDisplay(for: .B))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 110)
                .padding(.horizontal, 8)
                .padding(.top, 5)
                
                // Reset button
                Button(action: {
                    showingReset = true
                }) {
                    Text("Reset")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 5)
            }
        }
        .alert("Reset Match?", isPresented: $showingReset) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetMatch()
            }
        } message: {
            Text("This will reset all scores to 0-0")
        }
    }
    
    // MARK: - Scoring Logic
    
    enum Team {
        case A, B
    }
    
    func pointDisplay(for team: Team) -> String {
        let points = team == .A ? teamAPoints : teamBPoints
        let opponentPoints = team == .A ? teamBPoints : teamAPoints
        
        // Check for advantage/deuce
        if teamAPoints >= 3 && teamBPoints >= 3 {
            if points > opponentPoints {
                return "AD"
            } else if points == opponentPoints {
                return "40"
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
            // Team A wins game
            teamAGames += 1
            resetPoints()
        } else if teamBPoints >= 4 && teamBPoints >= teamAPoints + 2 {
            // Team B wins game
            teamBGames += 1
            resetPoints()
        }
    }
    
    func resetPoints() {
        teamAPoints = 0
        teamBPoints = 0
        isDeuce = false
    }
    
    func resetMatch() {
        teamAGames = 0
        teamBGames = 0
        resetPoints()
    }
}

#Preview {
    ContentView()
}
