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
    var sets: [DaySet]?
    
 
    init(date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.date = calendar.date(from: components)!
        self.sets = [DaySet]()
    }
    
    var dateString: String {
        return dateString(date: date)
    }
    
}

@Model
final class Exercise {
    @Attribute(.unique) var name: String
    var inject: [DayExercise] = [DayExercise]()
    var sets: [DaySet] = [DaySet]()
    var oneRMax: Double?
    
    
    init(name: String) {
        self.name = name
    }
}

@Model
final class DayExercise {
    var day: Day?
    @Relationship(deleteRule: .nullify)
    var surject: Exercise?
    @Relationship(deleteRule: .cascade)
    var sets: [DaySet]?
    
    
    init(day: Day, exercise: Exercise) {
        self.day = day
        self.surject = exercise
        self.sets = [DaySet]()
        day.exercises.append(self)
        exercise.inject.append(self)
    }
}


@Model
final class  DaySet{
    var weight: Int
    var reps: Int
    var day: Day?
    var dayExercise: DayExercise?
    @Relationship(deleteRule: .nullify, inverse: \Exercise.sets)
    var exercise: Exercise?
    
    var date: Date {return day!.date }
    var oneRepMax: Double {
        return  Double(weight) / (1.0278 - 0.0278 * Double(reps))
    }
    var volume: Int{
        return  reps * weight
    }
    
    init(weight: Int, reps: Int, day: Day, dayExercise: DayExercise) {
        self.weight = weight
        self.reps = reps
        self.dayExercise = dayExercise
        self.day = day
        self.exercise = dayExercise.surject!
        dayExercise.sets?.append(self)
        dayExercise.surject!.sets.append(self)
        day.sets?.append(self)
    }
}

