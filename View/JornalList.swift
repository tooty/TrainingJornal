//
//  JornalUIView.swift
//  Training
//
//  Created by Thomas Tichy on 04.09.23.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct JornalList: View {
    @State private var pickerDate: Date = Date()
    @State private var pickerDateShow: Bool = false
    @State private var fileExport: Bool = false
    @State private var fileImport: Bool = false
    
    @Query(sort: \Day.date, order: .reverse) var days: [Day]
    @Environment(\.modelContext) private var modelContext
    @Query var data: [DaySet]
    @State private var mydocument: URL = URL(fileURLWithPath: "")
    
    var body: some View {
        NavigationSplitView {
            List {
                if pickerDateShow {
                    VStack {
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
                        Button("Add Date"){
                            let newDate=Day(date: pickerDate)
                            modelContext.insert(newDate)
                            pickerDateShow.toggle()
                            
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                ForEach(days) {day in
                    NavigationLink(day.dateString,destination: ExerciseList(day:day))
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        let itemToDelete = days[index]
                        modelContext.delete(itemToDelete)
                    }
                })
                Button("testData"){
                    loadOld(context: modelContext)
                }
                Button("export"){
                    mydocument = exportJSON(mydata: data, context: modelContext)
                    fileExport.toggle()
                    
                }
                Button("load"){
                    fileImport.toggle()
                }
                Button("myShit"){
                    clameDB(context: modelContext)
                }
                Button("clear"){
                    distDB(context: modelContext)
                }
            }
            .animation(.bouncy, value: pickerDateShow)
            .toolbar {
                ToolbarItemGroup(placement: .automatic){
                    Button(pickerDateShow ? "Cancel" : "Add"){
                        pickerDateShow.toggle()
                    }
                    .buttonStyle(.automatic)
                    .animation(.easeInOut(duration: TimeInterval(0.1)), value: pickerDateShow)
                }
            }
            .navigationTitle("Jornal")
        }content:{
            if days.first != nil {
                ExerciseList(day: days.first!)
            }
        }
    detail:{
    }
    .fileExporter(
        isPresented: $fileExport,
        document: jsonExport(url: mydocument),
        contentType: .json,
        defaultFilename: "myfile.json"
    ) {
        result in
        if case .success = result {
            print(result)
        } else {
            print(result)
        }
    }
    .fileImporter(isPresented: $fileImport, allowedContentTypes: [.json]){ result in
        if case .success =  result{
            let url = try! result.get()
            _ = url.startAccessingSecurityScopedResource()
            loadOld(context: modelContext,url: url)
            url.stopAccessingSecurityScopedResource()
            do{
                try modelContext.save()
            } catch {
                print(error)
            }
        } else {
            print(result)
        }
    }
    }
    struct jsonExport: FileDocument {
        static var readableContentTypes: [UTType] = [.json]
        var url: URL?
        
        init(url: URL){
            self.url = url
        }
        
        init(configuration: ReadConfiguration) throws {
            let _ = configuration.file.regularFileContents
        }
        
        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            return try FileWrapper(url: url!)
        }
    }
}
