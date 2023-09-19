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
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    enum CodingKeys: String, CodingKey {
        case exerciseName
    }
    
    static func == (lhs: Exercise, rhs: Exercise)->Bool{
        return lhs.name == rhs.name
    }
    
    func maxWeight(reps: Int, exclude: [DaySet] ) -> Int{
        if oneRMax(exclude: exclude) == nil {
            return 0
        }
        let ret =  (1.0278 - 0.0278 * Double(reps)) * oneRMax(exclude:exclude)!
        return Int(ret)
    }
    
    func maxReps(weight: Int, exclude: [DaySet]) -> Int{
        if oneRMax(exclude: exclude) == nil {
            return 0
        }
        let ret = (1.0278-Double(weight)/oneRMax(exclude: exclude)!)/0.0278
        return Int(ret)
    }
}

extension DaySet: Encodable{
    enum CodingKeys: String, CodingKey {
        case weight
        case day
        case exerciseName
        case reps
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(weight, forKey: .weight)
        try container.encode(reps, forKey: .reps)
        try container.encode(dayExercise!.surject!.name, forKey: .exerciseName)
        try container.encode(date.timeIntervalSince1970*1000, forKey: .day)
    }
}


extension UTType {
    static var setsStack = UTType(exportedAs: "com.example.sets")
}
