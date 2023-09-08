//
//  ExerciseEditor.swift
//  Training
//
//  Created by Thomas Tichy on 05.09.23.
//

import SwiftUI
import SwiftData

struct ExerciseEditor: View {
    var day: Day
    var exercise: Exercise
    @Environment(\.modelContext) private var modelContext
        
    var body: some View {
        List {
            var filterdSets = day.sets.filter{$0.exercise == exercise}
            //var filterdSets = day.sets
            ForEach(filterdSets){set in
                SetView(set: set)
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let item = filterdSets[index]
                    modelContext.delete(item)
                    filterdSets.remove(at: index)
                }
            })
        }
        .navigationTitle(exercise.name)
        .toolbar(content: {
            Button("Add"){
                let newEntry = TrainingSet(weight: 1, reps: 1, day: day, exercise: exercise)
                modelContext.insert(newEntry)
                day.sets.append(newEntry)
            }.buttonStyle(.borderedProminent)
        })
    }
}
