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
        //DocumentGroup(editing: TrainingSet.self, contentType: .setsStack){
         //   ContentView()
        //}
        let configuration = ModelConfiguration(
            schema: Schema([Day.self, Exercise.self, DaySet.self]))
        let container = try? ModelContainer(for: Schema([Day.self, Exercise.self, DaySet.self]), configurations: configuration)
        WindowGroup {
            ContentView()
                .modelContainer(container!)
        }
    }
    
}


