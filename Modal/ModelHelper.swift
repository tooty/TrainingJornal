//
//  ModelHelper.swift
//  TrainingMulti
//
//  Created by Thomas Tichy on 12.09.23.
//

import Foundation
import SwiftData
import UniformTypeIdentifiers


extension Exercise: Hashable,Equatable {
    func oneRMax(exclude: [DaySet]) -> Double? {
        let set = sets.filter {!exclude.contains($0)}
        return set.max(by: {(a,b) in a.oneRepMax <= b.oneRepMax })?.oneRepMax ?? nil
    }
    
    func maxEffort(reps: Int, weight: Int ,exclude: [DaySet] )-> (reps: Int, weight: Int){
        guard let oneRMaxs = oneRMax(exclude:exclude) else {
            return (0,0)
        }
        let maxWeight =  (1.0278 - 0.0278 * Double(reps)) * oneRMaxs
        let maxReps = (1.0278-Double(weight)/oneRMaxs)/0.0278
        
        return (Int(maxReps),Int(maxWeight))
    }
   
    var lastInit: DaySet? {
        return sets.max(by: {$0.sort<$1.sort})
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sets)
    }
    
    enum CodingKeys: String, CodingKey {
        case exerciseName
    }
    
    static func == (lhs: Exercise, rhs: Exercise)->Bool{
        return lhs.name == rhs.name
    }
    
    
}

extension DayExercise: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.sets)
    }
}

extension DaySet: Encodable, Hashable{
    enum CodingKeys: String, CodingKey {
        case weight
        case day
        case exerciseName
        case reps
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.reps)
        hasher.combine(self.weight)
        hasher.combine(self.planned)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(weight, forKey: .weight)
        try container.encode(reps, forKey: .reps)
        try container.encode(dayExercise!.surject!.name, forKey: .exerciseName)
        try container.encode(date.timeIntervalSince1970*1000, forKey: .day)
    }
    
    
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


extension UTType {
    static var setsStack = UTType(exportedAs: "com.example.sets")
}

func calenderDate(_ date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    return calendar.date(from: components)!
}
