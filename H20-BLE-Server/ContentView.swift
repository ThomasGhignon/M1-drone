//
//  ContentView.swift
//  H20-BLE-Server
//
//  Created by GHIGNON Thomas on 25/12/2022.
//

import SwiftUI

struct ContentView: View {

    @State private var selectedView: String? = "configuration"
    
    var body: some View {
        NavigationView {
            VStack{
                List{
                    NavigationLink(destination: Configuration(), tag: "configuration", selection: $selectedView) {
                        Text("Configuration")
                    }
                    NavigationLink(destination: Manager(gameManager: GameManager(), utils: Utils()), tag: "manager", selection: $selectedView) {
                        Text("Manager")
                    }
                }
            }.padding()
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
            
        }.toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: { // 1
                    Image(systemName: "sidebar.leading")
                })
            }
        }
    }
    
    private func toggleSidebar() { // 2
       #if os(iOS)
       #else
       NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
       #endif
   }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
