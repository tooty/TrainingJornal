//
//  SetView.swift
//  Training
//
//  Created by Thomas Tichy on 06.09.23.
//

import SwiftUI


struct SetView: View {
    @Bindable var set: TrainingSet
    var body: some View {
        HStack{
            #if os(iOS)
            Text("Reps:")
            Picker("Reps",selection: $set.reps) {
                ForEach(1..<21){i in
                    Text(i.formatted()).tag(i)
                }
            }
            .frame(height: 100)
            .frame(height: 100)
            .pickerStyle(.wheel)
            Text("Weight:")
            Picker(selection: $set.weight, label: Text("Weight")) {
                ForEach(1..<200){i in
                    Text(i.formatted()).tag(i)
                }
            }
            .pickerStyle(.wheel)
                .frame(height: 100)
            #endif
            #if os(macOS)
                Stepper("Reps: \(set.reps)", value: $set.reps)
                Stepper("Weight: \(set.weight)", value: $set.weight)
            #endif
        }
    }
}
