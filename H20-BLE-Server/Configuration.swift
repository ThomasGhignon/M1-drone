//
//  Configuration.swift
//  H20-BLE-Server
//
//  Created by GHIGNON Thomas on 27/12/2022.
//

import SwiftUI

struct Configuration: View {
    @EnvironmentObject var bleInterface:BLEObservable
    var bleManager = BLEManager.instance
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    List(bleInterface.periphList.reversed()){ p in
                        HStack {
                            Text("\(p.name)")
                            Spacer(minLength: 10)
                            Text("\(p.blePeriph.identifier.uuidString)")
                        }
                    }
                }
                VStack{
                    Button("Start Scan") {
                        bleInterface.startScann()
                    }
                    .background(bleInterface.isScanning ? .blue : Color.gray)
                    .cornerRadius(20)
                    
                    Button("Stop Scan") {
                        bleInterface.stopScann()
                    }
                    .background(!bleInterface.isScanning ? .blue : Color.gray)
                    .cornerRadius(20)
                    
                }.padding(50)
            }
            List(bleManager.deviceList.reversed()) { d in
                VStack {
                    TriggerButton(label: d.name, state: d.state.rawValue == "ready" ? true : false, desc: d.state.rawValue) {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(d.peripheral.identifier.uuidString, forType: .string)
                    }
                }
            }
        }
    }
}

struct Configuration_Previews: PreviewProvider {
    static var previews: some View {
        Configuration()
    }
}
