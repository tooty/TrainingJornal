//
//  ChartControler.swift
//  TrainingMulti
//
//  Created by Thomas Tichy on 10.09.23.
//

import Foundation
import SwiftData
import CoreML
import CreateML
import TabularData
import Observation

@Observable class ChartViewModel: Identifiable {
    var exercise: DayExercise?
    var plotData: [String: [PlotData]] = [:]
    var domain: Int = 100000
  
    init() {
    }
    
    func update(){
        let queue = DispatchQueue(label: "new", attributes: .concurrent)
        queue.async {
            self.generatePlotData(planned: false)
        }
        queue.async {
            self.generatePlotData(planned: true)
        }
    }
    
    func generateOneR(sets: [PlotData]) -> [PlotData] {
        var oneR: [PlotData] = sets.map{ set in
            let y = Float16(set.y) / (1.0278 - 0.0278 * Float16(set.z!))
            return PlotData(x: set.x, y: y)
        }
        oneR = oneR.sorted(by: {(a,b)in
            a.x <= b.x
        })
        return oneR
    }
    
    func generateSets(planned: Bool) -> [PlotData] {
        guard exercise != nil else {
            print ("useless executio of func generateSets")
            return []
        }
        let sets = exercise!.surject!.sets.filter{$0.planned == planned}
        var ret = sets.map{ set in
            return PlotData(x: set.day!.date, y: Float16(set.weight), z: Float16(set.reps))
        }
        ret = ret.sorted(by: {(a,b)in
            a.x <= b.x
        })
        return ret
    }
    
    
    func generateVolume(allsets: [PlotData],dateSet: Array<Date>) -> [PlotData]{
        var volume: [PlotData] = allsets.map{set in
            return PlotData(x: set.x, y: Float16(set.y * set.z!))}
        
        volume = dateSet.map{buildSum($0,volume)}
        return volume
    }
    
    func generatePlotData(planned: Bool) {

        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async {
            let allsets = self.generateSets(planned: planned)
            
            guard allsets.count != 0  else {
                print("no Data to Plot")
                return
            }
            
            let dateSetTmp = Set(allsets.map { $0.x })
            let dateSet = dateSetTmp.sorted()
            
            var volume: [PlotData] = []
            var oneR: [PlotData] = []
            var oneRMax: [PlotData] = []
            
            oneR = self.generateOneR(sets: allsets)
            volume = self.generateVolume(allsets: allsets, dateSet: dateSet)
            
            oneRMax = dateSet.map { self.reduceMax($0, oneR) }
            
            let oneJearInterval:TimeInterval = 60*60*24*365
            let inOneJear = oneR.last!.x.addingTimeInterval(oneJearInterval)
            let result = self.genLin(oneR: oneRMax, predicion: inOneJear)
            
            DispatchQueue.main.async {
                if planned == true {
                    self.plotData["oneRMaxP"] = oneRMax
                    self.plotData["oneRP"] = oneR
                    self.plotData["volumeP"] = volume
                    self.plotData["allsetsP"] = allsets
                } else {
                    self.plotData["test"] = result
                    self.domain = Int(dateSet.last!.timeIntervalSince1970 - dateSet.first!.timeIntervalSince1970)
                    self.plotData["oneRMax"] = oneRMax
                    self.plotData["oneR"] = oneR
                    self.plotData["volume"] = volume
                    self.plotData["allsets"] = allsets
                }
            }
        }
    }
        
        func buildSum(_ day: Date,_ data: [PlotData]) -> PlotData{
            let sets: [PlotData] = data.filter{$0.x == day}
            var sum = sets.reduce(0) {$0 + $1.y}
            sum = sum/50
            return PlotData(x:day,y:sum)
        }
        
        func reduceMax(_ day: Date,_ data: [PlotData]) -> PlotData{
            let sets: [PlotData] = data.filter{$0.x == day}
            let ret = sets.max{(a,b) in a.y<b.y}!
            return ret
        }
        
    func genLin(oneR: [PlotData], predicion: Date) -> [PlotData]  {
            let dataFrame: DataFrame = ["Date": oneR.map{$0.x.timeIntervalSince1970},
                                        "oneR": oneR.map{Double($0.y)}]
            let modelParameters = MLLinearRegressor.ModelParameters()
            guard let model = try? MLLinearRegressor(trainingData: dataFrame,  targetColumn: "oneR", featureColumns: ["Date"], parameters: modelParameters) else {
                return oneR
            }
            print (model.modelParameters)
        print(predicion.formatted())
        let predFrame: DataFrame = ["Date": oneR.map{$0.x.timeIntervalSince1970}]
        let result = try! model.predictions(from: predFrame)
        print(result)
        let double: [Float16] = result.map({Float16($0 as! Double)})
        var ret = [PlotData]()
        for i in oneR.enumerated(){
            ret.append(PlotData(x:i.element.x, y: double[i.offset]))
        }
        return ret
        }
    }
    
    extension DaySet {
        var oneRepMax: Double {
            return  Double(weight) / (1.0278 - 0.0278 * Double(reps))
        }
        
        var volume: Int{
            return  reps * weight
        }
    }
    
struct PlotData {
        var x: Date
        var y: Float16 = 0
        var z: Float16?
    
}
