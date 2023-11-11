//
//  SetView.swift
//  Training
//
//  Created by Thomas Tichy on 06.09.23.
//

#if os(iOS)
import SwiftUI
import SwiftData


struct SetView: View {
    @Bindable var set: DaySet
    @State var viewToggle: Bool
    @State var maxEffort: (reps: Int,weight: Int) = (0,0)
    
    var body: some View {
        let exercise: Exercise? = set.exercise
        
        HStack{
            if viewToggle == true {
                VStack{
                    Text("Reps:")
                    Picker("Reps",selection: $set.reps) {
                        ForEach(1..<21,id: \.self){i in
                                Text(i.formatted())
                                .foregroundStyle(i > maxEffort.reps ? .red : .primary)
                        }
                    }
                    .frame(height: 100)
                    .pickerStyle(.wheel)
                }
                .onChange(of: set.reps, initial: true) {
                    maxEffort = exercise?.maxEffort(reps: set.reps, weight: set.weight, exclude: [set]) ?? (0,0)
                }
                VStack{
                    Text("Weight:")
                    Picker(selection: $set.weight, label: Text("Weight")) {
                        ForEach(1..<100){i in
                            let f = i * (exercise?.stepSize ?? 1)
                            Text(f.formatted()).tag(f)
                                .foregroundStyle(f > maxEffort.weight  ? .red : .primary)
                        }
                    }
                    .frame(height: 100)
                    .pickerStyle(.wheel)
                }
                .onChange(of: set.weight, {
                    maxEffort = exercise?.maxEffort(reps: set.reps, weight: set.weight, exclude: [set]) ?? (0,0)
                })
                
            } else {
                    Text("Reps:")
                    Text(set.reps.formatted())
                    Text("Weight:")
                    Text(set.weight.formatted())
            }
        }
        .foregroundStyle(set.planned == true ? Color.orange : Color.primary)
    }
}

struct SetViewPreview: View {
    @Query() var sets: [DaySet]
    @State private var chartViewModel = ChartViewModel()
    
    var body: some View {
            SetView(set: sets.randomElement()!,viewToggle: true)
                .environment(chartViewModel)
    }
}

#Preview {
    SetViewPreview()
        .modelContainer(getPreviewContainer())
}
#endif
