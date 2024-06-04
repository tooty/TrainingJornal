//
//  AddDay.swift
//  TrainingMulti
//
//  Created by Thomas Tichy on 15.04.24.
//

import SwiftUI

struct AddDay: View {
    @State private var selectedAdd: addOption = .day
    @State private var pickerDate: Date = Date.now
    @State private var segment: Set<DateComponents> = []
    @State private var segmentName: String = ""
    @Binding var pickerDateShow: Bool
    @Environment(\.modelContext) private var modelContext
    @State var oldSegments = Set<DateComponents>([])
    @FocusState var textFieldFocus
    @FocusState var datePickerFocus

    enum addOption: String {
        case day, segment
    }
    var body: some View {
                    VStack {
                        Picker("Flavor", selection: $selectedAdd) {
                            Text("Training").tag(addOption.day)
                            Text("Rouler").tag(addOption.segment)
                        }
                        .pickerStyle(.segmented)
                        if selectedAdd == .segment {
                            TextField("Segment Name", text: $segmentName)
                                .animation(.default, value: selectedAdd)
                                .textFieldStyle(.roundedBorder)
                                .focused($textFieldFocus)
                            VStack{
                                MultiDatePicker("Segment:",selection: $segment)
                                    .focused($datePickerFocus)
                                    .onChange(of: segment) {
                                        while segment.count > 2 {
                                           segment = oldSegments
                                        }
                                        oldSegments = segment
                                    }
                            }
                        } else {
                            DatePicker(
                                selection: $pickerDate,
                                displayedComponents: [.date],
                                label: {
                                }
                            )
#if os(iOS)
                        .datePickerStyle(.wheel)
#endif
                        .labelsHidden()
                        }
                        Button("Add Date",action: {
                            if selectedAdd == .segment {
                                guard let start = segment.sorted(by: {$0.date!<$1.date!}).first?.date else {
                                    return
                                }
                                guard let end = segment.sorted(by: {$0.date!<$1.date!}).last?.date else {
                                    return
                                }
                                guard segment.count == 2 else {
                                    datePickerFocus = true
                                    return
                                }
                                guard segmentName.count > 2 else {
                                    textFieldFocus = true
                                    return
                                }
                                let new = Segment(interval: DateInterval(start:start, end:end), name: segmentName)
                                modelContext.insert(new)
                                pickerDateShow.toggle()
                            } else {
                                let newDate=Day(date: pickerDate)
                                modelContext.insert(newDate)
                                pickerDateShow.toggle()
                            }
                        })
                        .buttonStyle(.borderedProminent)
                    }
    }
}

#Preview {
    struct myPreview: View {
        @State static var prevdate = Date()
        @State static var prvs = true
        
        var body: some View {
            AddDay(pickerDateShow: myPreview.$prvs)
        }
    }
    return myPreview()
}
