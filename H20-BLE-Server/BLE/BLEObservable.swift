//
//  BLEObservable.swift
//  SwiftUI_BLE
//
//  Created by Al on 26/10/2022.
//

import Foundation
import CoreBluetooth

struct Periph:Identifiable,Equatable{
    var id = UUID().uuidString
    var blePeriph:CBPeripheral
    var name:String
    
}

struct DataReceived:Identifiable,Equatable{
    var id = UUID().uuidString
    var content:String
}

class BLEObservable:ObservableObject{
    
    @Published var periphList:[Periph] = []
    @Published var devices = BLEManager.instance.deviceList
    @Published var connectedPeripheral:Periph? = nil
    @Published var connectionState:BLEDevice.ConnectionState = .disconnected
    @Published var dataReceived:[DataReceived] = []
    @Published var isScanning:Bool = false
//    let authorizedDevices = ["H2O_TW", "H2O_CORAL", "H2O_LAVA", "H2O_PIPE"]
    let authorizedDevices = ["H2O_TW", "H2O_CORAL", "H2O_LAVA", "H2O_PIPE"]
    
    init(){
        _ = BLEManager.instance
    }
    
    func startScann(){
        if BLEManager.instance.isBLEEnabled {
            BLEManager.instance.scan { p,s in
                
                self.isScanning = true
    
                let periph = Periph(blePeriph: p,name: s)
                
                if !self.periphList.contains(where: { per in
                    per.blePeriph == periph.blePeriph
                }) {
                    self.periphList.append(periph)
                }
                
                if self.authorizedDevices.contains(periph.name) || self.authorizedDevices.contains(periph.blePeriph.identifier.uuidString) {
                    BLEManager.instance.deviceList.insert(BLEManager.instance.createDevice(from: periph.blePeriph, name: periph.name))
                    self.connectTo(p: periph)
                    self.listen { r in
                        print(r)
                    }
                }
            }
        }
    }
    
    func stopScann(){
        self.isScanning = false
        BLEManager.instance.stopScan()
    }
    
    func connectTo(p:Periph){
        connectionState = .connecting
        self.updateDeviceState(id: p.blePeriph.identifier.uuidString, state: .connecting)
        BLEManager.instance.connectPeripheral(p.blePeriph) { cbPeriph in
            self.connectionState = .discovering
            self.updateDeviceState(id: p.blePeriph.identifier.uuidString, state: .discovering)
            BLEManager.instance.discoverPeripheral(cbPeriph) { cbPeriphh in
                self.connectionState = .ready
                self.connectedPeripheral = p
                self.updateDeviceState(id: p.blePeriph.identifier.uuidString, state: .ready)
            }
        }
        BLEManager.instance.didDisconnectPeripheral { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
    }
    
    func disconnectFrom(p:Periph){
        
        BLEManager.instance.disconnectPeripheral(p.blePeriph) { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
        
    }
        
    func updateDeviceState(id: String, state: BLEDevice.ConnectionState) {
        if let index = BLEManager.instance.deviceList.firstIndex(where: { $0.id == id }) {
            let device = BLEManager.instance.deviceList[index]
            device.state = state
        }
    }
    
    func sendData(data: Data, target: String, completion: @escaping (Bool) -> Void){
        for device in BLEManager.instance.deviceList {
            if device.peripheral.identifier.uuidString == target {
                if let characteristics = device.characteristics, characteristics.count > 1 {
                    let uuid = characteristics[1].uuid
                    BLEManager.instance.sendDataCustom(data: data, target: target, writeCharCBUUID: uuid) { c in
                        completion(true)
                    }
                } else {
                    print("Error : device.characteristics not available in BLEObservable.sendData()")
                }
            }
        }
    }
    
    func listen(c:((String)->())){
        
        BLEManager.instance.listenForTwMessages { data in
//            if let d = data{
//                let str = String(data: d, encoding: .utf8)
//            }
        }
    }
}
