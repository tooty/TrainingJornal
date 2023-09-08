//
//  ModelData.swift
//  Training
//
//  Created by Thomas Tichy on 04.09.23.
//

import Foundation
import Combine
import SwiftData

//var exeSets: [ExeSet] = load("datatest.json")
//let oldSets: [oldSet] = load("data.json")

@Model
final class Day {
    @Attribute(.unique) let date: Date
    var dateString: String {
        return dateString(date: date)
    }
    
    @Relationship var exercises: [Exercise]
    @Relationship var sets: [TrainingSet]
 
    init(date: Date) {
        self.date = date
        self.exercises = [Exercise]()
        self.sets = [TrainingSet]()
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
    
    init(name: String) {
        self.name = name
    }
}

@Model
final class TrainingSet {
    var weight: Int
    var reps: Int
    var day: Day?
    var exercise: Exercise?
    
    init(weight: Int, reps: Int, day: Day? = nil, exercise: Exercise? = nil) {
        self.weight = weight
        self.reps = reps
        self.exercise = exercise
        self.day = day
    }
}

extension Day: Equatable {
    static func == (lhs: Day, rhs: Day)->Bool{
        return lhs.dateString == rhs.dateString
    }
}

extension Exercise: Hashable {
        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }
}

