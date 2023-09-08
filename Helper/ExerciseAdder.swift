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
    @Query var exercises: [Exercise]
    let customExercise = Exercise(name: "custom")
    @State private var myexercise: Exercise = Exercise(name: "custom")
    @Binding var show: Bool
    var day: Day
    @State private var alert: Bool = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
            Text("Select exercise")
            let openExercises = exercises.filter {!day.exercises.contains($0)}
            Picker(selection: $myexercise, content: {
                Text("custom").tag(customExercise).foregroundColor(.blue)
                ForEach(openExercises){ exercise in
                    Text(exercise.name).tag(exercise)
                }
            }, label:{Text("hi")}).pickerStyle(.inline)
            Button("+"){
                print(myexercise)
                if (myexercise.name == "custom"){
                    alert.toggle()
                }
                else {
                    day.exercises.append(myexercise)
                    print(myexercise)
                    show.toggle()
                }
            }.alert("Chose Name", isPresented: $alert, actions:
                        {
                TextField("Name", text: $textField)
                Button("Add"){
                    let newExercise = Exercise(name: textField)
                    modelContext.insert(newExercise)
                    day.exercises.append(newExercise)
                    alert = false
                    show.toggle()
                }
            })
    }
}


//#Preview {
    //ExerciseAdder().modelContainer(for: Exercise.self)
//}
