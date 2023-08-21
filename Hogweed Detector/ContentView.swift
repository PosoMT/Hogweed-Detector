//
//  ContentView.swift
//  Hogweed Detector
//
//  Created by Pablo on 14.08.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var tabSelection: Int = 0
    
    var body: some View {
        TabView(selection: $tabSelection) {
            GalleryPickerScreen()
                .tag(0)
                .tabItem {
                    Label("Сканировать", systemImage: "eye")
                }
            ReportScreen()
                .tag(1)
                .tabItem {
                    Label("Report", systemImage: "fanblades.slash")
                }
            DetailsScreen()
                .tag(2)
                .tabItem {
                    Label("Details", systemImage: "info.circle")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
