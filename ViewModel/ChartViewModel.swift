//
//  ChartControler.swift
//  TrainingMulti
//
//  Created by Thomas Tichy on 10.09.23.
//

import Foundation
import Observation
import Accelerate
import CoreML

@Observable class ChartViewModel: Identifiable {
    var exercise: DayExercise?
    var plotData: [String: [PlotData]] = [:]
    var lin: Measurement<UnitMass>?
    
    init() {
    }
    
    func getDomain() -> (PlotData,PlotData)? {
        guard plotData["volume"]?.count ?? 0 > 0 else {
            return nil
        }
        let res = (plotData["volume"]!.first!, plotData["volume"]!.last!)
        return res
    }
    
    func predictOneRMax(){
        //self.plotData["oneRMax"]
        do {
            var model = try PredictOneRMax_2(configuration: .init())
            //model.prediction(day: reps: 10, exerciseName: exercise?.surject?.name ??"")
        } catch {
            return
        }
    }
    
    func getAnnotation(date: Date) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd MMMM"
        var ret = dateFormater.string(from: date)
        let sets: [PlotData] = plotData["allsets"]?.filter{
            $0.x == date
        } ?? []
        sets.forEach{ set in
            ret += "\n" + set.z!.formatted() + "x" + set.y.description
        }
       return ret
    }
    
    func getDomainSeconds() -> Int {
        guard let dom = getDomain() else {
            return 100000
        }
        let res1 = dom.1.x.timeIntervalSince(dom.0.x)
        let res = Int(res1 * 1.02)
        return res
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
            let oneR = Double(set.y.value / Double((1.0278 - 0.0278 * set.z!)))
            let y = Measurement<UnitMass>(value: oneR, unit: .kilograms)
            return PlotData(x: set.x, y: y)
        }
        oneR = oneR.sorted(by: {(a,b)in
            a.x <= b.x
        })
        return oneR
    }
    
    func generateSets(planned: Bool) -> [PlotData] {
        guard let exercise else {
            return []
        }
        guard let allsets = exercise.surject?.sets else {
            return []
        }
        let sets = allsets.filter{$0.planned == planned}
        var ret = sets.map{ set in
            return PlotData(x: set.day!.date, y: Measurement<UnitMass>(value: Double(set.weight),  unit: .kilograms), z: Float16(set.reps))
        }
        ret = ret.sorted(by: {(a,b)in
            a.x <= b.x
        })
        return ret
    }
    
    
    func generateVolume(allsets: [PlotData],dateSet: Array<Date>) -> [PlotData]{
        var volume: [PlotData] = allsets.map{set in
            return PlotData(x: set.x, y: Measurement<UnitMass>(value: Double(set.y.value * Double(set.z!)), unit: .kilograms))
        }
        
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
            
            let lin = self.genLin(oneRMax: oneRMax)
            var linear = Measurement<UnitMass>(value: 0, unit: .kilograms)
            if lin.count > 1 {
                linear = Measurement<UnitMass>(value: self.genLin(oneRMax: oneRMax)[1], unit: .kilograms)
            }
            
            DispatchQueue.main.async {
                if planned == true {
                    self.plotData["oneRMaxP"] = oneRMax
                    self.plotData["oneRP"] = oneR
                    self.plotData["volumeP"] = volume
                    self.plotData["allsetsP"] = allsets
                } else {
                    self.plotData["oneRMax"] = oneRMax
                    self.plotData["oneR"] = oneR
                    self.plotData["volume"] = volume
                    self.plotData["allsets"] = allsets
                    self.lin = linear
                }
            }
        }
    }
    
    func buildSum(_ day: Date,_ data: [PlotData]) -> PlotData{
        let sets: [PlotData] = data.filter{$0.x == day}
        var sum = sets.reduce(Measurement<UnitMass>(value: 0, unit: .kilograms)) {Measurement<UnitMass>(value: $0.value + $1.y.value, unit: .kilograms)}
        sum = sum/50
        return PlotData(x:day,y:sum)
    }
    
    func reduceMax(_ day: Date,_ data: [PlotData]) -> PlotData{
        let sets: [PlotData] = data.filter{$0.x == day}
        let ret = sets.max{(a,b) in a.y<b.y}!
        return ret
    }
    
    func genLin(oneRMax: [PlotData]) -> [Double] {
        
        guard !oneRMax.isEmpty else {
            return []
        }
        
        var rows = oneRMax.map{_ in Double(1)}
        var rowIndices = [Int32]()
        var bValues = [Double]()
        var parameter: [Double] = [0,0]
        
        for i in oneRMax.enumerated() {
            rows.append(Double((i.element.x.timeIntervalSince1970-Date().timeIntervalSince1970)/(60*60*24*30)))
            bValues.append(i.element.y.value)
            rowIndices.append(Int32(i.offset))
        }
        var columnStarts: [Int] = [0,oneRMax.count,rows.count]
        for i in oneRMax.enumerated() {
            rowIndices.append(Int32(i.offset))
        }
        let structure: SparseMatrixStructure = rowIndices.withUnsafeMutableBufferPointer { rowIndicesPtr in
            columnStarts.withUnsafeMutableBufferPointer { columnStartsPtr in
                let attributes = SparseAttributes_t()
                
                return SparseMatrixStructure(
                    rowCount: Int32(bValues.count),
                    columnCount: 2,
                    columnStarts: columnStartsPtr.baseAddress!,
                    rowIndices: rowIndicesPtr.baseAddress!,
                    attributes: attributes,
                    blockSize: 1
                )
            }
        }
        let b_length = Int32(bValues.count)
        
        rows.withUnsafeMutableBufferPointer { APtr in
            bValues.withUnsafeMutableBufferPointer { bPtr in
                 parameter.withUnsafeMutableBufferPointer { xPtr in
                     let a = SparseMatrix_Double(structure: structure, data: APtr.baseAddress!)
                     let b = DenseVector_Double(count: b_length, data: bPtr.baseAddress!)
                     let x =  DenseVector_Double(count: 2, data: xPtr.baseAddress!)
                     let status = SparseSolve(SparseLSMR(), a, b, x, SparsePreconditionerDiagScaling)
                    
                    if status != SparseIterativeConverged {
                        fatalError("Failed to converge. Returned with error \(status).")
                    }
                 }
            }
        }
        return parameter
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
        var y: Measurement<UnitMass>
        var z: Float16?
}
