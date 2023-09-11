//
//  ExerciseList.swift
//  Training
//
//  Created by Thomas Tichy on 04.09.23.
//

import SwiftUI 
import SwiftData
struct ExerciseList: View {
    
    var day: Day
    @State private var name: String = "myName"
    @State private var present: Bool = false
    @Environment(\.modelContext) private var modelContext
    var openExercises: [Exercise] {return allExercises.filter {!day.exercises.contains($0)} }
    @State private var textField = ""
    @Query(sort: \Exercise.name) var allExercises: [Exercise]
    
    
    
    var body: some View {
        List{
            if present {
                HStack{
                    TextField("custom Name", text: $textField).textFieldStyle(.roundedBorder).submitLabel(.done).onSubmit {
                        let newExercise = Exercise(name: textField)
                        modelContext.insert(newExercise)
                        day.exercises.append(newExercise)
                        present.toggle()
                    }
                }
            }
            ForEach(day.exercises){ exercise in
                NavigationLink(exercise.name, destination: ExerciseEditor(day: day,exercise: exercise))
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    day.exercises.remove(at: index)
                }
            })
            .onMove { day.exercises.move(fromOffsets: $0, toOffset: $1) }
        }
        .toolbar(content: {
                Menu {
                    Button("Other"){
                        present.toggle()
                    }.menuStyle(.button)
                    Divider()
                    ForEach(openExercises){x in
                        Button(x.name){
                            day.exercises.append(x)
                        }
                    }
                } label: {
                    Text("Add")
                }
        })
        .navigationTitle(day.dateString)
    }
}
