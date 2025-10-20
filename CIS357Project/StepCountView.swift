//
//  StepCountView.swift
//  CIS357Project
//
//  Created by Sam Uptigrove on 10/18/25.
//

import SwiftUI

struct StepCountView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject private var navigator: MyNavigator
    @State var dailySelected: Bool = true
    @State var weeklySelected: Bool = false
    @State var monthlySelected: Bool = false

    var body: some View {
            
            VStack {
                Text("Step Count")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                HStack() {
                    if dailySelected == true{
                        Button("Daily"){
                            dailySelected = true
                            weeklySelected = false
                            monthlySelected = false
                        }
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        
                    }
                    else {
                        Button("Daily"){
                            dailySelected = true
                            weeklySelected = false
                            monthlySelected = false
                        }
                        .background(Color.clear)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        
                    }
                    
                    Text("|")
                        .fontWeight(.bold)
                    
                    if weeklySelected == true{
                        Button("Weekly"){
                            dailySelected = false
                            weeklySelected = true
                            monthlySelected = false
                        }
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        
                        
                    }
                    else {
                        Button("Weekly"){
                            dailySelected = false
                            weeklySelected = true
                            monthlySelected = false
                        }
                        .background(Color.clear)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        
                    }
                    
                    Text("|")
                        .fontWeight(.bold)
                    
                    if monthlySelected == true{
                        Button("Monthly"){
                            dailySelected = false
                            weeklySelected = false
                            monthlySelected = true
                        }
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        
                        
                    }
                    else {
                        Button("Monthly"){
                            dailySelected = false
                            weeklySelected = false
                            monthlySelected = true
                        }
                        .background(Color.clear)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        
                    }
                    
                    
                }
                .background(
                    RoundedRectangle(cornerRadius:10)
                        .stroke(Color.black)
                )
                //            if onclick daily:
                //                    dailystepcount
                Spacer()
                if dailySelected == true {
                    Text(String(viewModel.dailySteps)
                    )
                    .font(.largeTitle)
                }
                else if weeklySelected == true {
                    Text(String(viewModel.weeklySteps)
                    )
                    .font(.largeTitle)
                }
                else {
                    Text(String(viewModel.monthlySteps)
                    )
                    .font(.largeTitle)
                }
                Spacer()
//                Button("Back"){
//                    navigator.navigateBackToRoot()
//                }
                
            }
            .navigationTitle("Step Count")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            
        }
        
        
    }

#Preview {
    StepCountView(viewModel: WorkoutViewModel()).environmentObject(MyNavigator())
}
