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
    @Attribute(.unique)
    let date: Date
    @Relationship(deleteRule: .cascade)
    var exercises: [DayExercise] = [DayExercise]()
    var sets: [DaySet] = [DaySet]()
    
 
    init(date: Date) {
        self.date = calenderDate(date)
    }
}

@Model
final class Exercise {
    @Attribute(.unique) var name: String
    var inject: [DayExercise] = [DayExercise]()
    var sets: [DaySet] = [DaySet]()
    var stepSize: Int = 1
    //var last: (weight: Int, reps: Int)? = (weight:1,reps:1)
    
    init(name: String) {
        self.name = name
    }
}

@Model
final class DayExercise {
    var day: Day?
    var surject: Exercise?
    @Relationship(deleteRule: .cascade)
    var sets: [DaySet] = [DaySet]()
    var sortedSets: [DaySet] {sets.sorted(by: {$0.sort < $1.sort})}
    var planedExercises: Bool {
        guard let _ = sets.first(where: {$0.planned == true}) else {
            return false
        }
        return true
    }
    
    
    init(day: Day, exercise: Exercise) {
        self.day = day
        self.surject = exercise
        day.exercises.append(self)
        exercise.inject.append(self)
    }
}


@Model
final class  DaySet{
    var weight: Int
    var reps: Int
    @Attribute(.unique) 
    var sort: Double
    var day: Day?
    var planned: Bool
    var dayExercise: DayExercise?
    var exercise: Exercise?
    var date: Date {return day!.date }
    
    
    init(weight: Int, reps: Int, day: Day, dayExercise: DayExercise, planned: Bool) {
        self.weight = weight
        self.reps = reps
        self.planned = planned
        self.sort = Date().timeIntervalSince1970
        self.day = day
        self.dayExercise = dayExercise
        self.exercise = dayExercise.surject!
        dayExercise.sets.append(self)
        dayExercise.surject!.sets.append(self)
        day.sets.append(self)
    }
}

