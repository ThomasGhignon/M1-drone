//
//  H20_BLE_ServerApp.swift
//  H20-BLE-Server
//
//  Created by GHIGNON Thomas on 25/12/2022.
//

import SwiftUI

@main
struct H20_BLE_ServerApp: App {
    @StateObject var bleInterface = BLEObservable()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(bleInterface)
        }
    }
}
