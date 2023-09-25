//
//  ExerciseSettings.swift
//  TrainingMulti
//
//  Created by Thomas Tichy on 13.09.23.
//

import SwiftUI
import SwiftData


struct ExerciseSettings: View {
    @Bindable var exercise: Exercise
    
    var body: some View {
        HStack{
            VStack{
                Text("Plan:")
            }
            
            Text("Weight step size: ")
            ControlGroup(content: {
                let numberFormatter: NumberFormatter = {
                    let nf = NumberFormatter()
                    nf.numberStyle = .decimal
                    return nf
                }()
                Button("+"){
                    exercise.stepSize += 1
                }
                TextField("", value: $exercise.stepSize,formatter: numberFormatter)
                Button("-"){
                    exercise.stepSize -= 1
                }
            })
            
        }
    }
    
}

//#Preview {
//    ExerciseSettings()
//    .modelContainer(for: Exercise.self)
//}
