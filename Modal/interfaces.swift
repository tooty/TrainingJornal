//
//  Set.swift
//  Training
//
//  Created by Thomas Tichy on 04.09.23.
//

import Foundation
import SwiftData

struct ExeSet: Identifiable,Hashable, Codable {
    let id: UUID
    var reps: Int
    var weight: Int
    var executed: Bool
}

struct DateExercise: Identifiable, Hashable, Codable{
    let id: UUID
    var name: String
    var sets: [ExeSet]
    
    mutating func addSet (executed: Bool, reps: Int = 1, weight: Int = 1) {
        let setEntry = ExeSet(id: UUID(), reps: reps, weight: weight, executed: executed)
        sets.append(setEntry)
    }
}

struct JornalDate: Identifiable, Hashable, Codable{
    let id: UUID
    let date: Date
    var exercises: [DateExercise]
    
    mutating func addExercise (exerciseName: String) {
        let exerciseEntry = DateExercise(id: UUID(), name: exerciseName, sets: [])
        if (!exercises.contains(exerciseEntry)) {
            exercises.append(exerciseEntry)
        } else {
            print("Allredy existing")
        }
    }
    
    mutating func addSet (exercise: String, weight: Int, reps:Int, executed: Bool) {
        addExercise(exerciseName: exercise)
        if let exercise = exercises.firstIndex(where: {x in x.name == exercise}) {
            exercises[exercise].addSet(executed: executed, reps: reps, weight: weight)
        }
    }
}

extension JornalDate: Equatable {
    static func == (lhs: JornalDate, rhs: JornalDate) -> Bool {
        return lhs.date == rhs.date
    }
}

extension DateExercise: Equatable {
    static func == (lhs: DateExercise, rhs: DateExercise) -> Bool {
        return lhs.name == rhs.name
    }
}

struct oldSet: Hashable,Codable{
    var weight: Int
    var day:Int
    var exerciseName:String
    var reps:Int
}

final class ModelData: ObservableObject {
    //@Published var days: [JornalDate] = getDates(sets: exeSets)
    @Published var days: [JornalDate] = []
    
    func loadOld(){
       // oldSets.forEach({seti in
            let setDate = Date(timeIntervalSince1970: TimeInterval(seti.day/1000))
            let myDate = addDate(date: setDate)
            days[myDate].addSet(exercise: seti.exerciseName, weight: seti.weight, reps: seti.reps, executed: true)
        })
    }
    
    func addDate(date: Date)-> Int {
        let jornalEntry = JornalDate(id: UUID(), date: date, exercises: [])
        if let finding = days.firstIndex(where: { x in x.date == jornalEntry.date}){
            return finding
        } else {
            days.append(JornalDate(id: UUID(), date: date, exercises: []))
            return days.count - 1
        }
    }
}


func getDateFormatter()-> DateFormatter{
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "de_DE")
    dateFormatter.setLocalizedDateFormatFromTemplate("dMMMMyy")
    return dateFormatter
}


func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else{
        fatalError("File not found")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

