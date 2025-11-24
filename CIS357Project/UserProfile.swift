// UserProfile.swift
import Foundation

struct UserProfile: Codable {
    var name: String = ""
    var age: Int = 18
    var height: Double = 170
    var weight: Double = 150
    var fitnessLevel: FitnessLevel = .beginner
    var photoData: Data? = nil
}

enum FitnessLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}
