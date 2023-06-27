//
//  BLEDevice.swift
//  H20-BLE-Server
//
//  Created by GHIGNON Thomas on 28/12/2022.
//

import Foundation
import CoreBluetooth

class BLEDevice:Identifiable, Hashable {
    
    enum ConnectionState: String {
        case disconnected = "Disconnected"
        case connecting = "Connecting"
        case discovering = "Discovering"
        case ready = "Ready"
    }

    
    var id = UUID().uuidString
    let peripheral: CBPeripheral
    var name:String
    var type:String
    var state:ConnectionState
    var services: [CBService]?
    var characteristics: [CBCharacteristic]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(peripheral.identifier)
    }

    init(peripheral: CBPeripheral, name: String) {
        self.id = peripheral.identifier.uuidString
        self.peripheral = peripheral
        self.name = name
        self.type = peripheral.name ?? "Unknown"
        self.state = .disconnected
    }
}

extension BLEDevice {
    static func == (lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        return lhs.peripheral.identifier == rhs.peripheral.identifier
    }
}
