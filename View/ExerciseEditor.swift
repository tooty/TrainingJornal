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
    @State private var showSheet = false
    @State private var detent: PresentationDetent = .medium
    
        
    var body: some View {
        List {
            var filterdSets = day.sets.filter{$0.exercise!.name == exercise.name}
            //var filterdSets = day.sets
            ForEach(filterdSets){set in
                SetView(set: set,exercise: exercise)
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
            ToolbarItemGroup(placement: .automatic) {
                Button("Chart",systemImage: "chart.xyaxis.line") {
                    showSheet = true
                }
                Button("Add", systemImage: "plus") {
                    var newEntry = TrainingSet(weight: exercise.latest?.weight ?? 1, reps: exercise.latest?.reps ?? 1, day: day, exercise: exercise)
                    modelContext.insert(newEntry)
                    exercise.latest = newEntry
                    day.sets.append(newEntry)
                }.buttonStyle(.automatic)
            }
        })
        #if os(iOS)
        .sheet(isPresented: $showSheet, content: {
            ChartView(exercise: exercise).presentationDetents([.medium,.fraction(0.2),.large])
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        })
        #endif
        #if os(macOS)
            ChartView(exercise: exercise)
        #endif
        
    }
}
