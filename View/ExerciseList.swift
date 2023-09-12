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
    var openExercises: [Exercise] {return allExercises}
    @State private var textField = ""
    @Query(sort: \Exercise.name) var allExercises: [Exercise]
    
    
    
    var body: some View {
        List{
            if present {
                HStack{
                    TextField("custom Name", text: $textField).textFieldStyle(.roundedBorder).submitLabel(.done).onSubmit {
                        let newExercise = Exercise(name: textField)
                        let newDayExercise = DayExercise(day: day, exercise: newExercise)
                        present.toggle()
                    }
                }
            }
            ForEach(day.exercises){ exercise in
                NavigationLink(exercise.surject!.name, destination: ExerciseEditor(dayExercise: exercise))
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let remove = day.exercises[index]
                    modelContext.delete(remove)
                }
            })
           // .onMove { day.exercises.move(fromOffsets: $0, toOffset: $1) }
        }
        .toolbar(content: {
                Menu {
                    Button("Other"){
                        present.toggle()
                    }.menuStyle(.button)
                    Divider()
                    ForEach(openExercises){x in
                        Button(x.name){
                            let new = DayExercise(day: day, exercise: x)
                            day.exercises.append(new)
                        }
                    }
                } label: {
                    Text("Add")
                }
        })
        .navigationTitle(day.dateString)
    }
}
