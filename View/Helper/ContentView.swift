//
//  ContentView.swift
//  Training
//
//  Created by Thomas Tichy on 02.09.23.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    init(){
    }
    var body: some View {
        JornalList()
    }
}
