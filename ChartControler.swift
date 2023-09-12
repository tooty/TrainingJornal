//
//  ChartControler.swift
//  TrainingMulti
//
//  Created by Thomas Tichy on 10.09.23.
//

import Foundation
import SwiftData

func generatePlotData(context: ModelContext, exercise: Exercise) -> ([plotData],[plotData],[plotData]) {
    //calculated twice
    var sets = [DaySet]()
    do {
        sets = try context.fetch(FetchDescriptor<DaySet>())
    } catch {
        print(error)
        return ([],[],[])
    }
    
    let setsExercise:[DaySet] = sets.filter{x in x.exercise?.name == exercise.name}
        
    var oneR: [plotData] = setsExercise.map{set in return plotData(x: set.day!.date, y: Double(set.oneRepMax))}
    var volume: [plotData] = setsExercise.map{set in return plotData(x: set.day!.date, y: Double(set.volume))}
    let dateSet = Set(oneR.map{return $0.x})
    
    oneR = oneR.sorted(by: {(a,b)in
        a.x <= b.x
    })
    
    var oneRMax = dateSet.map{reduceMax($0,oneR)}
    oneRMax = oneRMax.sorted(by: {(a,b)in
        a.x <= b.x
    })
    
    volume = dateSet.map{buildSum($0,volume)}
    oneRMax = oneRMax.sorted(by: {(a,b)in
        a.x <= b.x
    })
    
    exercise.oneRMax = oneRMax.max{(a,b) in a.y<b.y}!.y
    return (oneRMax,oneR,volume)
}
func buildSum(_ day: Date,_ data: [plotData]) -> plotData{
    let sets: [plotData] = data.filter{$0.x == day}
    var sum = sets.reduce(0) {$0 + $1.y}
    sum = sum/50
    return plotData(x:day,y:sum)
}

func reduceMax(_ day: Date,_ data: [plotData]) -> plotData{
    let sets: [plotData] = data.filter{$0.x == day}
    let ret = sets.max{(a,b) in a.y<b.y}!
    return ret
}

struct plotData {
    var x: Date
    var y: Double = 0
}
