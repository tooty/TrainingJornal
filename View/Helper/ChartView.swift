//
//  ChartView.swift
//  TrainingMulti
//
//  Created by Thomas Tichy on 09.09.23.
//

import SwiftUI
import SwiftData
import Charts

struct ChartView: View {
    @Environment(\.modelContext) private var modelContext
    //let exercise: Exercise = Exercise(name: "Kniebeuge")
    let exercise: Exercise
    @State var volume: Bool = false
    @State var oneRm: Bool = false
    @State var oneR: Bool = true
    
    var body: some View {
        
        let prepairdData: (oneRMax:[plotData],oneR:[plotData],volume:[plotData])
        = exercise.generatePlotData(exercise: exercise, planned: false)
        let planned = exercise.generatePlotData(exercise: exercise, planned: true)
        var color = Color("lightgray")
        GroupBox ("OneRMax - \(exercise.name)") {
            Chart{
                ForEach(prepairdData.oneRMax, id: \.x) { item in
                    if (oneRm){
                        LineMark(
                            x: .value("Date", item.x),
                            y: .value("Weight", item.y)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.red)
                        .opacity(0.3)
                    }
                }
                ForEach(prepairdData.volume, id: \.x) { item in
                    if (volume){
                        BarMark(
                            x: .value("Date", item.x),
                            y: .value("Volume", item.y)
                        )
                        .foregroundStyle(.teal)
                    }
                }
                ForEach(prepairdData.oneR, id: \.x) { item in
                    if (oneR){
                        PointMark(
                            x: .value("Date", item.x),
                            y: .value("Weight", item.y)
                        )
                        .opacity(0.3)
                    }
                }
                ForEach(planned.0, id: \.x) { item in
                    if (oneR){
                        PointMark(
                            x: .value("Date", item.x),
                            y: .value("Weight", item.y)
                        )
                        .foregroundStyle(.yellow)
                    }
                }
                ForEach(planned.2, id: \.x) { item in
                    if (volume){
                        BarMark(
                            x: .value("Date", item.x),
                            y: .value("Volume", item.y)
                        )
                        .foregroundStyle(.yellow)
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
                AxisMarks(position: .trailing)
            }
            ControlGroup{
                HStack{
                    Toggle("Volume",isOn: $volume)
                    Toggle("Intensity",isOn: $oneRm)
                    Toggle("Sets",isOn: $oneR)
                }
            }
        }
        .toggleStyle(.button)
        .backgroundStyle(Color.clear.gradient)
    }
}

#Preview {
    ChartView(exercise: Exercise(name: "Kniebeuge"))
        .modelContainer(for: [Day.self, Exercise.self, DaySet.self])
}
