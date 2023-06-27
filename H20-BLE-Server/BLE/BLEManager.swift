import Foundation
import SwiftUI
import CoreBluetooth
import Combine

class BLEManager: NSObject {
    static let instance = BLEManager()
    
    var isBLEEnabled = false
    var isScanning = false
    
    //let readTwCBUUID = CBUUID(string: "DB8DBA79-162B-4B36-9824-E87E2930F31D")
    let readTwCBUUID = CBUUID(string: "75FE609B-F1BC-45B9-8FAB-7C65162E4487")
    let readMoveCBUUID = CBUUID(string: "4635E96F-308B-4AF8-8114-B51C95E9334F")
    let readRfidCBUUID = CBUUID(string: "7D565784-53F3-4E8A-998C-79AF466074ED")
    let readLavaCBUUID = CBUUID(string: "35B5FA4E-DD71-474F-883C-DFB8CA508B60")
    let readPipeCBUUID = CBUUID(string: "E98F2C87-7C83-4CCF-A082-E05B2C041042")

    var centralManager: CBCentralManager?
    var connectedPeripherals = [CBPeripheral]()
    var readyPeripherals = [CBPeripheral]()
    var getCharacteristicUUID: [CBCharacteristic]?
    var deviceList:Set<BLEDevice> = []
    
    var scanCallback: ((CBPeripheral,String) -> ())?
    var connectCallback: ((CBPeripheral) -> ())?
    var disconnectCallback: ((CBPeripheral) -> ())?
    var didFinishDiscoveryCallback: ((CBPeripheral) -> ())?
    var globalDisconnectCallback: ((CBPeripheral) -> ())?
    var sendDataCallback: ((String?) -> ())?
    var twMessageReceivedCallback:((Data?)->())?
    var moveMessageReceivedCallback:((Data?)->())?
    var rfidMessageReceivedCallback:((Data?)->())?
    var lavaMessageReceivedCallback:((Data?)->())?
    var pipeMessageReceivedCallback:((Data?)->())?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func clear() {
        connectedPeripherals = []
        readyPeripherals = []
    }
    
    func scan(callback: @escaping (CBPeripheral,String) -> ()) {
        isScanning = true
        scanCallback = callback
        centralManager?.scanForPeripherals(withServices: [], options: [CBCentralManagerScanOptionAllowDuplicatesKey:NSNumber(value: false)])
    }
    
    func stopScan() {
        isScanning = false
        centralManager?.stopScan()
    }
    
    func listenForTwMessages(callback:@escaping(Data?)->()) {
        twMessageReceivedCallback = callback
    }
    
    func listenForMoveMessages(callback:@escaping(Data?)->()) {
        moveMessageReceivedCallback = callback
    }
    
    func listenForRfidMessages(callback:@escaping(Data?)->()) {
        rfidMessageReceivedCallback = callback
    }
    
    func listenForLavaMessages(callback:@escaping(Data?)->()) {
        lavaMessageReceivedCallback = callback
    }
    
    func listenForPipeMessages(callback:@escaping(Data?)->()) {
        pipeMessageReceivedCallback = callback
    }
    
    func connectPeripheral(_ periph: CBPeripheral, callback: @escaping (CBPeripheral) -> ()) {
        connectCallback = callback
        centralManager?.connect(periph, options: nil)
    }
    
    func disconnectPeripheral(_ periph: CBPeripheral, callback: @escaping (CBPeripheral) -> ()) {
        disconnectCallback = callback
        centralManager?.cancelPeripheralConnection(periph)
    }
    
    func didDisconnectPeripheral(callback: @escaping (CBPeripheral) -> ()) {
        disconnectCallback = callback
        globalDisconnectCallback = callback
    }
    
    func discoverPeripheral(_ periph: CBPeripheral, callback: @escaping (CBPeripheral) -> ()) {
        didFinishDiscoveryCallback = callback
        periph.delegate = self
        periph.discoverServices(nil)
        
    }
    
    func getCharForUUID(_ uuid: CBUUID, forperipheral peripheral: CBPeripheral) -> CBCharacteristic? {
        if let services = peripheral.services {
            for service in services {
                if let characteristics = service.characteristics {
                    for char in characteristics {
                        if char.uuid == uuid {
                            return char
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func sendDataCustom(data: Data, target: String, writeCharCBUUID: CBUUID,callback: @escaping (String?) -> ()) {
        sendDataCallback = callback
        for periph in readyPeripherals {
            if periph.identifier.uuidString == target {
                if let char = BLEManager.instance.getCharForUUID(writeCharCBUUID, forperipheral: periph) {
                    periph.writeValue(data, for: char, type: CBCharacteristicWriteType.withResponse)
                }
            }
        }
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let services = peripheral.services {
            let count = services.filter { $0.characteristics == nil }.count
            if count == 0 {
                for s in services {
                    for c in s.characteristics! {
                            peripheral.setNotifyValue(true, for: c)
                    }
                    for device in self.deviceList {
                        if device.peripheral.identifier == peripheral.identifier {
                            device.characteristics = s.characteristics!
                            print(device.characteristics!)
                        }
                    }
                }
                readyPeripherals.append(peripheral)
                didFinishDiscoveryCallback?(peripheral)
            }
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isBLEEnabled = true
        } else {
            isBLEEnabled = false
        }
        
        if central.state == .poweredOn {
                    // Start scanning for peripherals
                    central.scanForPeripherals(withServices: nil, options: nil)
                }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown"
        scanCallback?(peripheral,localName)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if !connectedPeripherals.contains(peripheral) {
            connectedPeripherals.append(peripheral)
            connectCallback?(peripheral)
        }
    }
        
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripherals.removeAll { $0 == peripheral }
        readyPeripherals.removeAll { $0 == peripheral }
        disconnectCallback?(peripheral)
    }

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic == getCharForUUID(readPipeCBUUID, forperipheral: peripheral){
            pipeMessageReceivedCallback?(characteristic.value)
        }
        
        if characteristic == getCharForUUID(readLavaCBUUID, forperipheral: peripheral){
            lavaMessageReceivedCallback?(characteristic.value)
        }
        
        if characteristic == getCharForUUID(readRfidCBUUID, forperipheral: peripheral){
            rfidMessageReceivedCallback?(characteristic.value)
        }
        
        if characteristic == getCharForUUID(readMoveCBUUID, forperipheral: peripheral){
            moveMessageReceivedCallback?(characteristic.value)
        }
        
        if characteristic == getCharForUUID(readTwCBUUID, forperipheral: peripheral){
            twMessageReceivedCallback?(characteristic.value)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        sendDataCallback?(peripheral.name)
    }
    
    func waitForCharacteristicUUID(completion: (() -> Void)?) {
        if let _ = getCharacteristicUUID {
            completion?()
            getCharacteristicUUID = nil
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.waitForCharacteristicUUID(completion: completion)
            }
        }
    }
    
    func createDevice(from peripheral: CBPeripheral, name: String) -> BLEDevice {
        let device = BLEDevice(peripheral: peripheral, name: name)
        return device
    }
}
