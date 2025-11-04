//
//  HealthkitIntegration.swift
//  CIS357Project
//
//  Created by Sam Uptigrove on 10/30/25.
//

//import Foundation
import SwiftUI
import Combine
import HealthKit



extension Date {
    static var startOfDay: Date {
        return Calendar.current.startOfDay(for: Date())
    }
    static var startOfWeek: Date {
        let sevendays = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return Calendar.current.startOfDay(for: sevendays)
    }
    static var startOfMonth: Date {
        let thirtydays = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        return Calendar.current.startOfDay(for: thirtydays)
    }
}

class HealthkitIntegration: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var dailySteps: Int = 0  
    @Published var weeklySteps: Int = 0
    @Published var monthlySteps: Int = 0
    
    init() {
        let steps = HKQuantityType(.stepCount)
        let activityArr: Set = [steps]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: activityArr)
                print("Authorized")
                dailyStepsUpdate()
                weeklyStepsUpdate()
                monthlyStepsUpdate()
            } catch {
                print("Error grabbing data: \(error.localizedDescription)")
            }
        }
        // repeats request to refresh data every 30 seconds
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.dailyStepsUpdate()
            self.weeklyStepsUpdate()
            self.monthlyStepsUpdate()

            
        }

    }
    func dailyStepsUpdate() {
        let steps = HKQuantityType(.stepCount)
        let theDate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: theDate) {_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else{
                print("error grabbing data")
                return
            }
            let stepCount = Int(quantity.doubleValue(for: .count()))
//        let activity = Activities(id: 0, title: "Today's Steps", subtitles: "Goal 10,000", image: "figure.walk", amount: String(Int(stepCount)))
            DispatchQueue.main.async {
                self.dailySteps = stepCount
            }
//        print(stepCount)
        }
        healthStore.execute(query)
    }
    func weeklyStepsUpdate() {
        let steps = HKQuantityType(.stepCount)
        let theDate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: theDate) {_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else{
                print("error grabbing data")
                return
            }
            let stepCount = Int(quantity.doubleValue(for: .count()))
            DispatchQueue.main.async {
                self.weeklySteps = stepCount
            }
        }
        healthStore.execute(query)
    }
    func monthlyStepsUpdate() {
        let steps = HKQuantityType(.stepCount)
        let theDate = HKQuery.predicateForSamples(withStart: .startOfMonth, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: theDate) {_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else{
                print("error grabbing data")
                return
            }
            let stepCount = Int(quantity.doubleValue(for: .count()))
            DispatchQueue.main.async {
                self.monthlySteps = stepCount
            }
        }
        healthStore.execute(query)
    }
}
