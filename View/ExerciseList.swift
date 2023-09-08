//
//  ExerciseList.swift
//  Training
//
//  Created by Thomas Tichy on 04.09.23.
//

import SwiftUI 
import SwiftData
    struct ExerciseList: View { 
        
    var day: Day
    @State private var name: String = "myName"
    @State private var present: Bool = false
    @Environment(\.modelContext) private var modelContext
    
    
    
        var body: some View {
            NavigationView {
                List{
                    ControlGroup{
                        Button("+"){
                            present.toggle()
                        }.buttonStyle(.automatic)
                            .frame(maxWidth: .infinity)
                    }.sheet(isPresented: $present,
                            content: {
                        ExerciseAdder(show: $present, day: day).presentationDetents([.medium])
                    })
                    ForEach(day.exercises){ exercise in
                        NavigationLink(exercise.name, destination: ExerciseEditor(day: day,exercise: exercise))
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            let itemToDelete = day.exercises[index]
                            modelContext.delete(itemToDelete)
                        }})
                }
                .navigationTitle(day.dateString)
            }
        }
}

#Preview {
        List{
            ControlGroup {
                Button("+"){
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(5.0)
            }.frame(alignment: .center)
            Text("next")
        }
}
