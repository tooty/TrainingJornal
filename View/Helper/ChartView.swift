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
    let exercise: Exercise
    
    @State var volume: Bool = true
    @State var oneRm: Bool = true
    @State var oneR: Bool = true
    @State var prepairdData: (oneRMax:[plotData],oneR:[plotData],volume:[plotData]) = ([],[],[])
    @State var planned: (oneRMax:[plotData],oneR:[plotData],volume:[plotData]) = ([],[],[])
    
    var body: some View {
        
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
        .onChange(of: exercise.hashValue, initial: true, {
            DispatchQueue(label: "mine").async {
                prepairdData = exercise.generatePlotData(modelContext: modelContext, exercise: exercise, planned: false)
                planned = exercise.generatePlotData(modelContext: modelContext, exercise: exercise, planned: true)
            }
        })
        .toggleStyle(.button)
        .backgroundStyle(Color.clear.gradient)
    }
}
