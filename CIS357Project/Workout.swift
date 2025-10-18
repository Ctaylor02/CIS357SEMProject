//
//  Workout.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 10/18/25.
//

import Foundation

struct Workout: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var date: Date? = nil
    var duration: TimeInterval = 0
    var isCompleted: Bool = false
    var note: String? = nil
}
