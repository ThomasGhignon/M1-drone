//
//  GameManager.swift
//  H20-BLE-Server
//
//  Created by GHIGNON Thomas on 31/12/2022.
//

import SwiftUI


struct Manager: View {
    @ObservedObject var gameManager: GameManager
    @EnvironmentObject var bleInterface:BLEObservable
    var utils: Utils
    
    var body: some View {
        HStack {
            List(gameManager.steps) { step in
                
                if step.triggerable == true {
                    TriggerButton(label: step.name, state: step.state, desc: step.desc) {
                        self.gameManager.start(step: step.index)
                    }
                } else {
                    NoneTriggerButton(label: step.name, state: step.state)
                }
            }
            VStack {
                Button("Reset Coral") {
                    gameManager.resetCoral()
                }
                .background(bleInterface.isScanning ? .blue : Color.gray)
                .cornerRadius(20)
            }.padding(50)
        }
    }
}
