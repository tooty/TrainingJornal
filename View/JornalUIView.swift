//
//  JornalUIView.swift
//  Training
//
//  Created by Thomas Tichy on 04.09.23.
//

import SwiftUI
import SwiftData

struct JornalList: View {
    @State private var pickerDate: Date = Date()
    @State private var pickerDateShow: Bool = false
    @State private var fileExport: Bool = false
    
    @Query(sort: \Day.date, order: .reverse) var days: [Day]
    @Environment(\.modelContext) private var modelContext
    @Query var data: [TrainingSet]
    @State var mydocument: String = ""
    
    
    var body: some View {
        NavigationSplitView {
            List {
                if pickerDateShow {
                    VStack {
                        DatePicker(
                            selection: $pickerDate,
                            displayedComponents: [.date],
                            label: {
                            }
                        )
                        #if os(iOS)
                        .datePickerStyle(.wheel)
                        #endif
                        .labelsHidden()
                        Button("Add Date"){
                            let newDate=Day(date: pickerDate)
                            modelContext.insert(newDate)
                            pickerDateShow.toggle()
                            
                        }
                        .buttonStyle(.borderedProminent)
                    }
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
                Button("export"){
                    mydocument = exportJSON(mydata: data, context: modelContext).absoluteString
                }
                Button("load"){
                    loadOld(context: modelContext)
                }
                Button("myShit"){
                    clameDB(context: modelContext)
                }
                Button("clear"){
                    distDB(context: modelContext)
                }
            }
            .animation(.bouncy, value: pickerDateShow)
            .toolbar {
                ToolbarItemGroup(placement: .automatic){
                    Button(pickerDateShow ? "Cancel" : "Add"){
                       pickerDateShow.toggle()
                    }
                    .buttonStyle(.automatic)
                    .animation(.smooth, value: pickerDateShow)
                }
            }
            .navigationTitle("Jornal")
        }content:{
            Text("Content")
        }
    detail:{
        Text("hi")
    }
    }
}

#Preview {
    JornalList()
        .modelContainer(for: [Day.self, Exercise.self, TrainingSet.self])
}
