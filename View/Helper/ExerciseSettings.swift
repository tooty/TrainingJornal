//
//  ExerciseSettings.swift
//  TrainingMulti
//
//  Created by Thomas Tichy on 13.09.23.
//

import SwiftUI
import SwiftData


struct ExerciseSettings: View {
    @AppStorage("planning") private var planning = false
    @Bindable var exercise: Exercise
    
    var body: some View {
        HStack{
            VStack{
                Text("Settings").font(.title)
                Form{
                    Toggle("Plan:", isOn: $planning)
                    Stepper(value: $exercise.stepSize, label: {
                        Text("Weight Steps: \(exercise.stepSize)")
                    })
                }
            }
            
        }
    }
    
}

//#Preview {
//    ExerciseSettings()
//    .modelContainer(for: Exercise.self)
//}
