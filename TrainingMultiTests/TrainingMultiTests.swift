//
//  TrainingMultiTests.swift
//  TrainingMultiTests
//
//  Created by Thomas Tichy on 12.10.23.
//

import XCTest
import SwiftData
@testable import TrainingMulti

final class TrainingMultiTests: XCTestCase {
    var modelContainer: ModelContainer? = nil
    var chartViewModel: ChartViewModel? = nil

    @MainActor override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Day.self, Exercise.self, DaySet.self, DayExercise.self, configurations: config)
        
        guard let modelContainer else {
            print("no Model context")
            return
        }
        let descriptor = FetchDescriptor<DayExercise>()
        let dayExercises = try modelContainer.mainContext.fetch(descriptor)
        let randomeExercise = dayExercises.first{$0.surject?.name == "Kniebeuge"}
       
        loadOld(context: modelContainer.mainContext)
        chartViewModel = ChartViewModel()
    }
    
    
    func testLinearisation() {
        var data = [PlotData]()
        data.append(PlotData(x: Date(),y: Measurement(value: 0.0, unit: UnitMass.kilograms)))
        data.append(PlotData(x: Date() + TimeInterval(60*60*24*30) ,y: Measurement(value: 0.0, unit: UnitMass.kilograms)))
        XCTAssert(chartViewModel!.genLin(oneRMax: data)[1].rounded() == 1)
        XCTAssert(chartViewModel!.genLin(oneRMax: []).isEmpty)
    }
    
    func testTime() {
        measure{
            getPreviewContainer()
        }
    }
}
