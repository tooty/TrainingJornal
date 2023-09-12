//
//  ModelHelper.swift
//  TrainingMulti
//
//  Created by Thomas Tichy on 12.09.23.
//

import Foundation
import SwiftData
import UniformTypeIdentifiers

func exportJSON(mydata: Encodable, context: ModelContext)-> URL {
    var dir = getDocumentsDirectory()
    dir = dir.appendingPathComponent("sets.json")
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
        let stream =  try encoder.encode(mydata)
        try stream.write(to: dir)
    } catch { print(error) }
    return dir
}

func getDocumentsDirectory() -> URL {
    // find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}

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
}

extension Day: Equatable{
    static func == (lhs: Day, rhs: Day)->Bool{
        return lhs.dateString == rhs.dateString
    }
    
    enum CodingKeys: String, CodingKey {
        case day
    }
    
    func dateString(date:Date)-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMM")
        return dateFormatter.string(from: date)
    }
}

extension DaySet: Encodable {
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
