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
        GroupBox ("Steigerung pro Monat \(chartViewModel.lin?.formatted() ?? "")"){
            Picker("Scope", selection: $visibleDomain, content: {
                Text("Month").tag(Scope.Month)
                Text("3 Month").tag(Scope.ThreeMonth)
                Text("All").tag(Scope.All)
            })
            .pickerStyle(.segmented)
            
            if (chartViewModel.plotData["volume"]?.count ?? 0 > 1){
            Chart {
                    if (oneRm){
                        ForEach(chartViewModel.plotData["oneRMax"] ?? [], id: \.x) { item in
                            AreaMark(
                                x: .value("Date", item.x, unit: .day),
                                y: .value("Weight", item.y.value)
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
                                y: .value("Volume", item.y.value)
                            )
                            .foregroundStyle(.teal)
                        }
                    }
                    if (oneR){
                        ForEach(chartViewModel.plotData["allsets"] ?? [], id: \.x) { item in
                            PointMark(
                                x: .value("Date", item.x),
                                y: .value("Weight",item.y.value)
                            )
                            .opacity(1)
                            .symbolSize(Double(item.z! * 15))
                            .symbol(Circle().strokeBorder(lineWidth: 0.5))
                        }
                    }
                    if (oneR){
                        ForEach(chartViewModel.plotData["oneRP"] ?? [], id: \.x) { item in
                            PointMark(
                                x: .value("Date", item.x),
                                y: .value("Weight", item.y.value)
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
                                y: .value("Volume", item.y.value)
                            )
                            .foregroundStyle(.yellow)
                        }
                    }
                    if selectedDate != nil{
                        let calenderDate = getNearestDate(selectedDate!, array: chartViewModel.plotData["volume"]!)
                        RuleMark (
                            x: .value("date", calenderDate)
                        )
                        .foregroundStyle(.blue.opacity(0.6))
                        .annotation(position: .leading, alignment: .top, spacing: 0,overflowResolution: .init(x: .fit(to: .chart),y: .disabled)){
                            RoulerAnnotation(date: calenderDate,plotData: chartViewModel.plotData["allsets"]!)
                        }
                    }
                }
                .chartXVisibleDomain(length: visibleDomain.length ?? chartViewModel.getDomainSeconds())
                .chartScrollableAxes(.horizontal)
                .chartScrollPosition(initialX: Date.now)
                .chartXSelection(value: $selectedDate)
                .chartYAxis {
                    AxisMarks(position: .trailing)
                }
            } else {
                Text("Not enough Data")
            }
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

struct PredictionMark: ChartContent {
    var chartViewModel: ChartViewModel
    var body: some ChartContent {
        PointMark(
            x: .value("Date", chartViewModel.plotData["oneRMax"]?.first?.x ?? Date(), unit: .day),
            y: .value("Weight", chartViewModel.plotData["oneRMax"]?.first?.y.value ?? 0)
        )
            .interpolationMethod(.monotone)
            .foregroundStyle(.green.gradient)
            .opacity(0.1)
        let firstDate = chartViewModel.plotData["oneRMax"]?.first?.x.timeIntervalSince(Date()) ?? 0
        let interpolation = chartViewModel.plotData["oneRMax"]?.first?.y.value ?? 0 * (chartViewModel.lin?.value ?? 0) * (firstDate / (3600 * 24 * 30))
        PointMark(
            x: .value("Date", Date(), unit: .day),
            y: .value("Weight", interpolation)
        )
            .interpolationMethod(.monotone)
            .foregroundStyle(.green)
    }
}

struct RoulerAnnotation: View {
    let date: Date
    let plotData : [PlotData]
    let dateFormat = Date.FormatStyle().weekday(.short).day(.twoDigits).month(.twoDigits)

    var body: some View {
        VStack{
            Text(date.formatted(dateFormat)).bold()
            ForEach(plotData.filter{$0.x == date }, id: \.x) { item in
                Text(" \(item.z?.formatted() ?? "")x\(item.y.formatted())")
            }
        }
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(Color.secondary.opacity(0.8))
            }
    }
}

enum Scope: String, CaseIterable, Identifiable {
    case Month,ThreeMonth, All
    var id: Self { self }
}

extension Scope {
    var length : Int? {
        switch self {
        case .Month:
            return 30*3600*24
        case .ThreeMonth:
            return 3*30*3600*24
        case .All:
            return nil
        }
    }
}

struct ChartViewPreview: View {
    @Query() var dayExercises: [DayExercise]
    @State private var chartViewModel = ChartViewModel()
    
    var body: some View {
        ChartView(exercise: dayExercises.first{$0.surject?.name == "Lat Zug"}!)
                .environment(chartViewModel)
    }
}

#Preview {
    ChartViewPreview()
        .modelContainer(getPreviewContainer())
}
