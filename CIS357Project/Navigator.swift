//
//  Navigator.swift
//  CIS357Project
//
//  Created by Aiden Mack on 10/18/25.
//
import SwiftUI
import Combine

enum Route: Hashable {
    case History
    case workout(Workout)
    case summary(Workout)
    case stepCount
}

class MyNavigator: ObservableObject {
    @Published var navPath: [Route] = []
    
    func navigate(to dest: Route) {
        navPath.append(dest)
    }
    
    func navigateBack() {
        navPath.removeLast()
    }
    
    func navigateBackToRoot() {
        navPath.removeAll()
    }
}
