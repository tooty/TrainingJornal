//
//  ModelData.swift
//  Training
//
//  Created by Thomas Tichy on 04.09.23.
//

import Foundation
import SwiftData

@Model
final class Day {
    @Attribute(.unique) let date: Date
    var exercises: [Exercise]
    @Relationship(deleteRule: .cascade) var sets: [DaySet]
    var dateString: String {
        return dateString(date: date)
    }
 
    init(date: Date) {
        self.date = date
        self.exercises = [Exercise]()
        self.sets = [DaySet]()
    }
    
    func dateString(date:Date)-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMM")
        return dateFormatter.string(from: date)
    }
}

@Model
final class Exercise {
    @Attribute(.unique) var name: String
    var oneRMax: Double?
    //var latest: TrainingSet?
    
    func maxWeight(reps: Int) -> Int{
        let oneRepMax = oneRMax ?? 0
        let ret =  (1.0278 - 0.0278 * Double(reps)) * oneRepMax
        
        return Int(ret)
    }
    
    func maxReps(weight: Int) -> Int{
        let oneRepMax = oneRMax ?? 1
        let ret = (1.0278-Double(weight)/oneRepMax)/0.0278
        print(ret)
        
        return Int(ret)
    }
    
    init(name: String) {
        self.name = name
    }
}


@Model
final class  DaySet{
    var weight: Int
    var reps: Int
    //@Relationship(deleteRule: .cascade,inverse: \Day.sets )
    var day: Day?
    var exercise: Exercise?
    
    var date: Date {return day?.date ?? Date()}
    var oneRepMax: Double {
        return  Double(weight) / (1.0278 - 0.0278 * Double(reps))
    }
    var volume: Int{
        return  reps * weight
    }
    
    init(weight: Int, reps: Int, day: Day?, exercise: Exercise) {
        self.weight = weight
        self.reps = reps
        self.exercise = exercise
        self.day = day
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.weight = try values.decode(Int.self, forKey: .weight)
        self.reps = try values.decode(Int.self, forKey: .reps)
        let exeString = try values.decode(String.self, forKey: .exerciseName)
        self.exercise = Exercise(name: exeString)
        let dayInt = try values.decode(Int.self, forKey: .day)
        self.day = Day(date: Date(timeIntervalSince1970: TimeInterval(dayInt/1000)))
    }
}

