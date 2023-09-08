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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Day.self, Exercise.self, TrainingSet.self],isUndoEnabled: true)
        }
    }
}


