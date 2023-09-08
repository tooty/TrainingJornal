//
//  JornalUIView.swift
//  Training
//
//  Created by Thomas Tichy on 04.09.23.
//

import SwiftUI
import SwiftData

struct JornalList: View {
    @State private var date: Date = Date()
    @State private var datePicker: Bool = false
    @Query(sort: \Day.date, order: .reverse) var days: [Day]
    @Environment(\.modelContext) private var modelContext
    
    
    var body: some View {
            NavigationView {
                List {
                    if datePicker {
                        DatePicker(
                            selection: $date,
                            displayedComponents: [.date],
                            label: {
                                Button("Add Date"){
                                    let newDate=Day(date: date)
                                    modelContext.insert(newDate)
                                    datePicker.toggle()
                                }
                            }
                        )
                        .datePickerStyle(.compact)
                    }
                    ForEach(days) {day in
                        NavigationLink(day.dateString,destination: ExerciseList(day:day))
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            let itemToDelete = days[index]
                            modelContext.delete(itemToDelete)
                        }
                    })
                }
                .toolbarRole(.editor)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("+"){
                            datePicker.toggle()
                        }
                    }
                }
                .navigationTitle("Jornal")
            }
        }
}

#Preview {
    JornalList()
        .modelContainer(for: [Day.self, Exercise.self, TrainingSet.self])
}
