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
    @State private var present: Bool = false
    @Environment(\.modelContext) private var modelContext
    var openExercises: [Exercise] {return allExercises}
    @State private var textField = "New exercise name"
    @Query(sort: \Exercise.name) var allExercises: [Exercise]
    
    var body: some View {
        List{
            if present {
                HStack{
                    TextField("custom Name", text: $textField).textFieldStyle(.roundedBorder).submitLabel(.done).onSubmit {
                        let newExercise = Exercise(name: textField)
                        _ = DayExercise(day: day, exercise: newExercise)
                        present.toggle()
                    }
                }
            }
            ForEach(day.exercises){ exercise in
                NavigationLink(exercise.surject!.name, destination: ExerciseEditor(dayExercise: exercise))
                .foregroundColor(exercise.planedExercises == true ? .orange : .primary)
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let remove = day.exercises[index]
                    modelContext.delete(remove)
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


struct ExerciseListPreview: View {
    @State private var chartViewModel = ChartViewModel()
    @Query(sort: \Day.date, order: .reverse) var days: [Day]
    
    var body: some View {
        ExerciseList(day: days.first!)
        .environment(chartViewModel)
    }
}

#Preview {
    ExerciseListPreview()
        .modelContainer(getPreviewContainer())
}
