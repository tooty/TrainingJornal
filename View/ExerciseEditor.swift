//
//  ExerciseEditor.swift
//  Training
//
//  Created by Thomas Tichy on 05.09.23.
//

import SwiftUI
import SwiftData

struct ExerciseEditor: View {
    var dayExercise: DayExercise
    @Environment(\.modelContext) private var modelContext
    @State private var showSheet = false
    @State private var detent: PresentationDetent = .medium
    
        
    var body: some View {
        List {
            ForEach(dayExercise.sets!){seti in
                SetView(set: seti,exercise: seti.dayExercise!.surject!)
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let item = dayExercise.sets![index]
                    modelContext.delete(item)
                }
            })
        }
        .navigationTitle(dayExercise.surject!.name)
        .toolbar(content: {
            ToolbarItemGroup(placement: .automatic) {
                Button("Chart",systemImage: "chart.xyaxis.line") {
                    showSheet = true
                }
                Button("Add", systemImage: "plus") {
                    let newEntry = DaySet(weight:  1, reps:  1, day: dayExercise.day!, dayExercise: dayExercise)
                }.buttonStyle(.automatic)
            }
        })
        #if os(iOS)
        .sheet(isPresented: $showSheet, content: {
            ChartView(exercise: dayExercise.surject!).presentationDetents([.medium,.fraction(0.2),.large])
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        })
        #endif
        #if os(macOS)
        ChartView(exercise: dayExercise.surject!)
        #endif
        
    }
}
