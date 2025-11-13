//
//  Workout.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 10/18/25.
//

import Foundation

struct Workout: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    var date: Date? = nil
    var duration: TimeInterval = 0
    var isCompleted: Bool = false
    var note: String? = nil

    // Initialize with default id so it's encodable/decodable-friendly
    init(id: UUID = UUID(), name: String, date: Date? = nil, duration: TimeInterval = 0, isCompleted: Bool = false, note: String? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.duration = duration
        self.isCompleted = isCompleted
        self.note = note
    }
}
