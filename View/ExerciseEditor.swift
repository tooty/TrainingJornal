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
    @State private var showChart = false
    @State private var showSettings = false
    @State private var detent: PresentationDetent = .fraction(0.3)
    @State private var selected = -1
    @Query var settings: [Settings]
    
    var body: some View {
        VStack{
            List {
                ForEach(dayExercise.sortedSets){seti in
                    let index:Int = dayExercise.sets.firstIndex(of: seti)!
                    let binding = Binding<Bool>(
                        get: {selected == index},
                        set: {v in selected = index
                            if (v == false)
                            { selected = -1}
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
                        Button(action: {
                            seti.planned.toggle()
                        }, label: {
                            if (seti.planned == true){
                                Label("Panned", systemImage: "pencil.circle").tint(.orange)
                            }
                            else {
                                Label("Done", systemImage: "pencil.circle.fill").tint(.green)
                            }
                        })
                    })
                    #endif
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        let item = dayExercise.sets[index]
                        dayExercise.sets.remove(at: index)
                        modelContext.delete(item)
                    }
                })
                .onMove {
                    dayExercise.sets.move(fromOffsets: $0, toOffset: $1)
                }
                .animation(.easeInOut, value: dayExercise.sets)
            }
            .navigationTitle(dayExercise.surject!.name)
            .toolbar(content: {
                ToolbarItemGroup(placement: .automatic) {
                    Button("Settings",systemImage: "gear") {
                        showSettings.toggle()
                    }
                    Button("Chart",systemImage: "chart.xyaxis.line") {
                        showChart.toggle()
                    }
                    Button("Add", systemImage: "plus") {
                        _ = DaySet(
                            weight:  dayExercise.surject?.lastInit?.weight ?? 1,
                            reps: dayExercise.surject?.lastInit?.reps ?? 1 ,
                            day: dayExercise.day!,
                            dayExercise: dayExercise,
                            planned: false
                        )
                        clameDB(context: modelContext)
                        print("daySetcount"+dayExercise.sets.count.formatted())
                    }.buttonStyle(.automatic)
                }
            })
            if horizontalSizeClass != .compact {
                ChartView(exercise: dayExercise.surject!)
            }
        }
        .frame(maxHeight: .infinity)
        #if os(iOS)
            .sheet(isPresented: $showChart, content: {
                ChartView(exercise: dayExercise.surject!).presentationDetents([.medium,.fraction(0.3),.large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            })
            .sheet(isPresented: $showSettings, content: {
                ExerciseSettings(exercise: dayExercise.surject!).presentationDetents([.medium,.fraction(0.3),.large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            })
        #endif
    }
}
