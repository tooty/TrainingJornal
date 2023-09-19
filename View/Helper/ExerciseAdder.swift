//
//  ExerciseAdder.swift
//  Training
//
//  Created by Thomas Tichy on 07.09.23.
//

import SwiftUI
import SwiftData

struct ExerciseAdder: View {
    @State private var textField: String = ""
    @State private var myexercise = Exercise(name: "custom").id
    @Query var exercises: [Exercise]
    @Binding var show: Bool
    var day: Day
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        let openExercises = exercises.filter {!day.exercises.contains($0)}
        HStack{
            Text("Select exercise").font(.title)
            TextField("custom Name", text: $textField).textFieldStyle(.roundedBorder).submitLabel(.done).onSubmit {
                onSubmit()
            }
        }
    }
    
    func onSubmit(){
        print(myexercise)
            if (myexercise.name == "custom"){
                let newExercise = Exercise(name: textField)
                modelContext.insert(newExercise)
                day.exercises.append(newExercise)
                show.toggle()
            }
            else {
                day.exercises.append(myexercise)
                show.toggle()
            }
    }
}


//#Preview {
    //ExerciseAdder().modelContainer(for: Exercise.self)
//}
