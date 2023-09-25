//
//  ChartControler.swift
//  TrainingMulti
//
//  Created by Thomas Tichy on 10.09.23.
//

import Foundation
import SwiftData

extension Exercise {
    func oneRMax(exclude: [DaySet]) -> Double? {
        let set = sets.filter {!exclude.contains($0)}
        return set.max(by: {(a,b) in a.oneRepMax <= b.oneRepMax })?.oneRepMax ?? nil
    }
    
    var lastInit: DaySet? {
        return sets.sorted(by: {
            (a,b) in a.sort<b.sort
        }).last
    }
    
    func generateOneR(sets: [DaySet]) -> [plotData]{
        var oneR: [plotData] = sets.map{ set in
            return plotData(x: set.day!.date, y: Double(set.oneRepMax))
        }
        oneR = oneR.sorted(by: {(a,b)in
            a.x <= b.x
        })
        return oneR
    }
    
    func generateVolume(sets: [DaySet],dateSet:Set<Date>) -> [plotData]{
        var volume: [plotData] = sets.map{set in
            return plotData(x: set.day!.date, y: Double(set.volume))}
        
        volume = dateSet.map{buildSum($0,volume)}
        return volume
    }
    
    func generatePlotData(modelContext: ModelContext, exercise: Exercise, planned: Bool) -> ([plotData],[plotData],[plotData]) {
        var sets = exercise.sets
        sets = sets.filter{$0.planned == planned}
        let dateSet = Set(sets.map{return $0.date})
        var oneR: [plotData] = []
        var volume: [plotData] = []
        
        oneR = self.generateOneR(sets: sets)
        volume = self.generateVolume(sets: sets,dateSet: dateSet)
        var oneRMax: [plotData] = dateSet.map{self.reduceMax($0,oneR)}
        oneRMax = oneRMax.sorted(by: {(a,b)in
            a.x <= b.x
        })
        
        oneRMax = oneRMax.sorted(by: {(a,b)in
            a.x <= b.x
        })
        
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
}

extension DaySet {
    var oneRepMax: Double {
        return  Double(weight) / (1.0278 - 0.0278 * Double(reps))
    }
    
    var volume: Int{
        return  reps * weight
    }
}

struct plotData {
    var x: Date
    var y: Double = 0
}

extension Day {
    var dateString: String {
        return dateString(date: date)
    }
    
    func dateString(date:Date)-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMM")
        return dateFormatter.string(from: date)
    }
}
