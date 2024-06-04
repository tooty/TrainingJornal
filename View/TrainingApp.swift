//
//  TrainingApp.swift
//  Training
//
//  Created by Thomas Tichy on 02.09.23.
//

import SwiftUI
import SwiftData

@main

struct TrainingApp: App {
    @State private var chartViewModel = ChartViewModel()
    var body: some Scene {
        //DocumentGroup(editing: [Day.self, Exercise.self, DaySet.self, DayExercise.self, Settings.self], contentType: .setsStack ){
        //    ContentView()
        //}
        WindowGroup {
            Journal()
                .modelContainer(for: [Segment.self, Day.self, Exercise.self, DaySet.self, DayExercise.self])
                .environment(chartViewModel)
        }
    }
}
