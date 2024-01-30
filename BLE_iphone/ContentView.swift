//
//  ContentView.swift
//  BLE_iphone
//
//  Created by Souta Takada on 2024/01/31.
//

import Foundation
import CoreBluetooth

final class BLEManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral? = nil
    private var characteristic: CBCharacteristic? = nil
    private var peripheralName: String = "esp-test-device"
    private var serviceUUID: CBUUID = CBUUID(string: "3c3996e0-4d2c-11ed-bdc3-0242ac120002")
    private var writeCharacteristicUUID: CBUUID = CBUUID(string:"3C399A64-4D2C-11ED-BDC3-0242AC120002")
    private var notifyCharacteristicUUID: CBUUID = CBUUID(string:"3C399C44-4D2C-11ED-BDC3-0242AC120002")
    
    @Published private(set) var isKeyLocked = false
    @Published private(set) var isConnected = false
    @Published private(set) var logText = ""
    @Published var isDemoMode = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scan() {
        guard centralManager.state == .poweredOn else { return }
        logText.append("start scan" + "\n")
        centralManager.scanForPeripherals(withServices: [serviceUUID])
    }
    
    func writeDataToBLEDevice() {
        isKeyLocked.toggle()
        let writeString = isKeyLocked ? "ON" : "OFF"
        guard let writeData = writeString.data(using: .utf8) else { return }
        if let peripheral = self.peripheral, let writeCharacteristic = self.characteristic{
            peripheral.writeValue(writeData, for: writeCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func disconnectPeripheral() {
        if let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            logText.append("unknown" + "\n")
        case .resetting:
            logText.append("resetting" + "\n")
        case .unsupported:
            logText.append("unsupported" + "\n")
        case .unauthorized:
            logText.append("unauthorized" + "\n")
        case .poweredOff:
            logText.append("poweredOff" + "\n")
        case .poweredOn:
            logText.append("poweredOn" + "\n")
        default:
            logText.append("default" + "\n")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        logText.append("start connect" + "\n")
        let peripheralName = advertisementData["kCBAdvDataLocalName"] as? String
        logText.append("kCBAdvDataLocalName: \(peripheralName ?? "No LocalName")" + "\n")
        logText.append((peripheral.name ?? "No PeripheralName") + "\n")
        if peripheralName == self.peripheralName {
            self.peripheral = peripheral
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logText.append("didConnect" + "\n")
        isConnected = true
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral) {
        logText.append("didFailToConnect" + "\n")
        isConnected = false
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard error == nil else { return }
        logText.append("didDisconnectPeripheral" + "\n")
        isConnected = false
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        logText.append("didDiscoverServices" + "\n")
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics!{
            if characteristic.uuid == writeCharacteristicUUID {
                self.characteristic = characteristic
                logText.append("WriteCharacteristicUUID" + "\n" + "\(characteristic.uuid)" + "\n")
            }
            if characteristic.uuid == notifyCharacteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
                logText.append("NotifyCharacteristicUUID" + "\n" + "\(characteristic.uuid)" + "\n")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            logText.append( "error： \(error!.localizedDescription)" + "\n")
            return
        }
        logText.append("didWriteValue" + "\n")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            logText.append("通知の受け取りに失敗しました： \(error.localizedDescription)")
        } else {
            let receivedData = String(bytes: characteristic.value!, encoding: String.Encoding.ascii)
            logText = ""
            logText.append("\(receivedData ?? "breaked data")"+"\n")
            
        }
    }

    }

import SwiftUI

struct ContentView: View {
    @StateObject private var bleManager = BLEManager()
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView{
                    Text(bleManager.logText)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 400, alignment: .leading)
                .background(
                    Color.gray,
                    in: RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 3)
                )
                
                VStack(alignment: .leading, spacing: 30) {
                    VStack(alignment: .leading) {
                        Text("接続状態： " + (bleManager.isConnected ? "接続" : "未接続"))
                        Text("カチカチ電源状態： " + (bleManager.isKeyLocked ? "ON" : "OFF"))
                    }
                    HStack(spacing: 100) {
                        Button {
                            bleManager.scan()
                        } label: {
                            Text("接続")
                        }
                        .disabled(bleManager.isConnected)
                        Button {
                            bleManager.disconnectPeripheral()
                        } label: {
                            Text("切断")
                        }
                        .disabled(!bleManager.isConnected)
                        Button {
                            bleManager.writeDataToBLEDevice()
                        } label: {
                            Text("switch")
                        }
                        .disabled(!bleManager.isConnected)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("実験用BLEシステム")
        }
    }
}

#Preview {
    ContentView()
}
