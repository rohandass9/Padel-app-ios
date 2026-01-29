//
//  HealthKitManager..swift
//  PadelScoreTracker
//
//  Created by Rohan Das on 16/11/2025.
//

import Foundation
import HealthKit
import SwiftUI
import Combine

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    // Data we want to read/write
    // Data we want to read/write
    let typesToShare: Set = [
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]
    
    let typesToRead: Set = [
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]
    
    // Request authorization
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        
        await MainActor.run {
            self.isAuthorized = true
        }
    }
    
    // Save a padel workout
    func saveWorkout(startDate: Date, endDate: Date, caloriesBurned: Double) async throws {
        let duration = endDate.timeIntervalSince(startDate)
        
        // Create workout
        let workout = HKWorkout(
            activityType: .tennis, // Closest match to padel
            start: startDate,
            end: endDate,
            duration: duration,
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: caloriesBurned),
            totalDistance: nil,
            metadata: [
                HKMetadataKeyWorkoutBrandName: "Padel Tracker",
                "Sport": "Padel"
            ]
        )
        
        try await healthStore.save(workout)
    }
    
    // Check authorization status
    func checkAuthorizationStatus() -> Bool {
        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return false
        }
        
        let status = healthStore.authorizationStatus(for: energyType)
        return status == .sharingAuthorized
    }
}

enum HealthKitError: Error {
    case notAvailable
    case authorizationFailed
}
