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

}

extension Day: Equatable{
    static func == (lhs: Day, rhs: Day)->Bool{
        return lhs.dateString == rhs.dateString
    }
    
    enum CodingKeys: String, CodingKey {
        case day
    }
}

extension DaySet: Codable {
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
        try container.encode(exercise?.name, forKey: .exerciseName)
        try container.encode(date.timeIntervalSince1970*1000, forKey: .day)
    }
    
}


extension UTType {
    static var setsStack = UTType(exportedAs: "com.example.sets")
}
