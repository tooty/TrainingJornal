//
//  SetView.swift
//  Training
//
//  Created by Thomas Tichy on 06.09.23.
//

#if os(iOS)
import SwiftUI


struct SetView: View {
    @Bindable var set: DaySet
    @State var viewToggle: Bool
    
    var body: some View {
        let exercise: Exercise? = set.exercise
        let repMax = exercise?.maxReps(weight: set.weight, exclude: [set])
        let weightMax = exercise?.maxWeight(reps: set.reps, exclude: [set])
        HStack{
            if viewToggle == true {
                VStack{
                    Text("Reps:")
                    Picker("Reps",selection: $set.reps) {
                        ForEach(1..<21){i in
                            if (i > repMax ?? 0){
                                Text(i.formatted()).tag(i).foregroundStyle(.red)
                            }else{
                                Text(i.formatted()).tag(i)
                            }
                        }
                    }
                    .frame(height: 100)
                    .frame(height: 100)
                    .pickerStyle(.wheel)
                }
                VStack{
                    Text("Weight:")
                    Picker(selection: $set.weight, label: Text("Weight")) {
                        ForEach(1..<200){i in
                            let f = i * (exercise?.stepSize ?? 1)
                            if (f > weightMax ?? 0){
                                Text(f.formatted()).tag(f).foregroundStyle(.red)
                            }else{
                                Text(f.formatted()).tag(f)
                            }
                        }
                    }
                    .frame(height: 100)
                    .pickerStyle(.wheel)
                }
                
            } else {
                    Text("Reps:")
                    Text(set.reps.formatted())
                    Text("Weight:")
                    Text(set.weight.formatted())
            }
        }
        
    }
}

#endif
