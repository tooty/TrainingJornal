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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @AppStorage("planning") private var planning = false
    @State private var sheetContent: SheetContent = .none
    @State private var disclosIndex = -1
    
    var body: some View {
        let sortedSets = dayExercise.sortedSets
        VStack{
            List {
                ForEach(sortedSets, id: \.id){seti in
                    let index:Int = dayExercise.sets.firstIndex(of: seti)!
                    let binding = Binding<Bool>(
                        get: {disclosIndex == index},
                        set: {v in
                            disclosIndex = index
                            if (v == false)
                            { disclosIndex = -1}
                        })
#if os(macOS)
                    SetView(set: seti, viewToggle: true)
#else
                    DisclosureGroup(isExpanded: binding, content: {
                        SetView(set: seti, viewToggle: true)
                    }, label: {
                        SetView(set: seti, viewToggle: false)
                    })
                    .swipeActions(edge: .leading,content: {
                        Button {
                            seti.planned.toggle()
                        } label: {
                            if (seti.planned == true){
                                Label("Done", systemImage: "pencil.circle.fill")
                            }
                            else {
                                Label("Panned", systemImage: "pencil.circle").tint(.orange)
                            }
                        }
                    })
#endif
                }
                .onMove(perform: { indices, newOffset in
                    let buffer = sortedSets.map{$0.sort+1/10000}
                    var buff2 = sortedSets
                    buff2.move(fromOffsets: indices, toOffset: newOffset)
                    buffer.enumerated().forEach{buff2[$0.offset].sort = $0.element}
                })
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        let item = sortedSets[index]
                        modelContext.delete(item)
                        dayExercise.sets.removeAll(where: {$0 == item})
                    }
                })
            }
            .navigationTitle(dayExercise.surject!.name)
            .toolbar(content: {
                ToolbarItemGroup(placement: .automatic) {
                    Button("Settings",systemImage: "gear") {
                        sheetContent = .settings
                    }
                    Button("Chart",systemImage: "chart.xyaxis.line") {
                        sheetContent = .chart
                    }
                    Button("Add", systemImage: "plus") {
                        let new = DaySet(
                            weight:  dayExercise.surject?.lastInit?.weight ?? 1,
                            reps: dayExercise.surject?.lastInit?.reps ?? 1 ,
                            day: dayExercise.day!,
                            dayExercise: dayExercise,
                            planned: planning
                        )
                        modelContext.insert(new)
                    }.buttonStyle(.automatic)
                }
            })
            if horizontalSizeClass != .compact {
                ChartView(exercise: dayExercise)
            }
        }
        .frame(maxHeight: .infinity)
        .sheet(isPresented: Binding<Bool>(get: {
            sheetContent == .chart
        }, set: {
            if $0 == false {
                sheetContent = .none
            } else {
                sheetContent = .chart
            }
        })
               , content: {
                ChartView(exercise: dayExercise)
                .presentationDetents([.medium,.fraction(0.3),.large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        })
        .sheet(isPresented: Binding<Bool>(get: {
            sheetContent == .settings
        }, set: {
            if $0 == false {
                sheetContent = .none
            } else {
                sheetContent = .settings
            }
        })
               , content: {
            ExerciseSettings(exercise: dayExercise.surject!).presentationDetents([.medium,.fraction(0.3),.large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        })
    }
    
    enum SheetContent {
        case chart,settings,none
    }
    
}
