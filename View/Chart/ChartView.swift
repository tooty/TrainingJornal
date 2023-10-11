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
    @State var volume: Bool = true
    @State var oneRm: Bool = true
    @State var oneR: Bool = true
    @State var selectedDate: Date?
    @State var visibleDomain: Scope = .All
    var exercise: DayExercise
    @Environment(ChartViewModel.self) private var chartViewModel
    
    var body: some View {
        GroupBox {
            Picker("Scope", selection: $visibleDomain, content: {
                Text("Week").tag(Scope.Week)
                Text("Month").tag(Scope.Month)
                Text("All").tag(Scope.All)
            })
            .pickerStyle(.segmented)
            
            Chart {
                    ForEach(chartViewModel.plotData["test"] ?? [], id: \.x) { item in
                        LineMark(
                            x: .value("Date", item.x, unit: .day),
                            y: .value("Weight", item.y)
                        )
                        .foregroundStyle(.green.gradient)
                    }
                if (oneRm){
                    ForEach(chartViewModel.plotData["oneRMax"] ?? [], id: \.x) { item in
                        AreaMark(
                            x: .value("Date", item.x, unit: .day),
                            y: .value("Weight", item.y)
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(.red.gradient)
                        .opacity(0.1)
                    }
                }
                if (volume){
                    ForEach(chartViewModel.plotData["volume"] ?? [], id: \.x) { item in
                        BarMark(
                            x: .value("Date", item.x),
                            y: .value("Volume", item.y)
                        )
                        .foregroundStyle(.teal)
                    }
                }
                if (oneR){
                    ForEach(chartViewModel.plotData["allsets"] ?? [], id: \.x) { item in
                        PointMark(
                            x: .value("Date", item.x),
                            y: .value("Weight",item.y)
                        )
                        .opacity(1)
                        .symbolSize(Double(item.z! * 30))
                        .symbol(Circle().strokeBorder(lineWidth: 0.5))
                    }
                }
                if (oneR){
                    ForEach(chartViewModel.plotData["oneRP"] ?? [], id: \.x) { item in
                        PointMark(
                            x: .value("Date", item.x),
                            y: .value("Weight", item.y)
                        )
                        .foregroundStyle(.yellow)
                        .symbolSize(Double(item.z ?? 0))
                        .symbol(Circle().strokeBorder(lineWidth: 0.5))
                    }
                }
                if (volume){
                    ForEach(chartViewModel.plotData["volumeP"] ?? [], id: \.x) { item in
                        BarMark(
                            x: .value("Date", item.x),
                            y: .value("Volume", item.y)
                        )
                        .foregroundStyle(.yellow)
                    }
                }
                if selectedDate != nil{
                    let calenderDate = calenderDate(selectedDate!)
                    RuleMark (
                        x: .value("date", calenderDate)
                    )
                }
            }
        }
        .chartXVisibleDomain(length: visibleDomain.length ?? chartViewModel.domain)
        .chartScrollableAxes(.horizontal)
        .chartXSelection(value: $selectedDate)
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
            .toggleStyle(.button)
        }
        .onChange(of: exercise.hashValue, initial: true, {
            chartViewModel.exercise = exercise
            chartViewModel.update()
        }
        )
    }
}



enum Scope: String, CaseIterable, Identifiable {
    case Week,Month,All
    var id: Self { self }
}

extension Scope {
    var length : Int? {
        switch self {
        case .Week:
            return 7*3600*24
        case .Month:
            return 30*3600*24
        case .All:
            return nil
        }
    }
}
