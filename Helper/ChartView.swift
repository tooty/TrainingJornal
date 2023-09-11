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
    
    var body: some View {
        
        let prepairdData: (oneRMax:[plotData],oneR:[plotData],volume:[plotData])
        = generatePlotData(context: modelContext, exercise: exercise)
        GroupBox ("OneRMax - \(exercise.name)") {
            Chart{
                ForEach(prepairdData.oneRMax, id: \.x) { item in
                    LineMark(
                        x: .value("Date", item.x),
                        y: .value("Weight", item.y)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.red)
                    .opacity(0.3)
                }
                ForEach(prepairdData.volume, id: \.x) { item in
                    BarMark(
                        x: .value("Date", item.x),
                        y: .value("Volume", item.y)
                    )
                    .foregroundStyle(.teal)
                }
                ForEach(prepairdData.oneR, id: \.x) { item in
                    PointMark(
                        x: .value("Date", item.x),
                        y: .value("Weight", item.y)
                    )
                    .opacity(0.3)
                }
                RuleMark(y: .value("Best Effort", exercise.oneRMax ?? 0))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 1))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
                AxisMarks(position: .trailing)
            }
        }
    }
    
}

#Preview {
    ChartView(exercise: Exercise(name: "Kniebeuge"))
        .modelContainer(for: [Day.self, Exercise.self, TrainingSet.self])
}
