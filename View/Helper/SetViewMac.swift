//
//  SetViewMac.swift
//  TrainingMulti
//
//  Created by Thomas Tichy on 19.09.23.
//
#if os(macOS)

import SwiftUI

struct SetView: View {
    @Bindable var set: DaySet
    @State var viewToggle: Bool
    
    var body: some View {
        let exercise: Exercise? = set.exercise
        //let repMax = exercise?.maxReps(weight: set.weight, exclude: [set])
        //let weightMax = exercise?.maxWeight(reps: set.reps, exclude: [set])
        let hStack = HStack{
                let numberFormatter: NumberFormatter = {
                    let nf = NumberFormatter()
                    nf.numberStyle = .decimal
                    return nf
                }()
                ControlGroup(content: {
                    Button("+"){
                        set.reps += 1
                    }
                    TextField("", value: $set.reps,formatter: numberFormatter)
                    Button("-"){
                        set.reps -= 1
                    }
                }).controlSize(.extraLarge)
                ControlGroup(content: {
                    Button("+"){
                        set.weight += exercise!.stepSize
                    }
                    TextField("", value: $set.weight,formatter: numberFormatter)
                    Button("-"){
                        set.weight -= exercise!.stepSize
                    }
                }).controlSize(.extraLarge)
                }
        hStack
            if (set.planned == true){
                hStack.foregroundColor(.yellow)
            }
        }
    }
#endif

