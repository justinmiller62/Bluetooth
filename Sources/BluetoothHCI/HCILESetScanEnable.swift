//
//  HCILESetScanEnable.swift
//  Bluetooth
//
//  Created by Alsey Coleman Miller on 6/14/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation

// MARK: - Method

extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
        var chars: [unichar] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
    
}

public extension BluetoothHostControllerInterface {
    
    /// Scan LE devices for the specified time period.
    func lowEnergyScan(duration: TimeInterval,
                       filterDuplicates: Bool = true,
                       parameters: HCILESetScanParameters = .init(),
                       timeout: HCICommandTimeout = .default) throws -> [HCILEAdvertisingReport.Report] {
        
        let startDate = Date()
        let endDate = startDate + duration
        
        var foundDevices: [HCILEAdvertisingReport.Report] = []
        foundDevices.reserveCapacity(1)
        
        try lowEnergyScan(filterDuplicates: filterDuplicates,
                          parameters: parameters,
                          timeout: timeout,
                          shouldContinue: { Date() < endDate },
                          foundDevice: { foundDevices.append($0) })
        
        return foundDevices
    }
    
    /// Scan LE devices.
    func lowEnergyScan(filterDuplicates: Bool = true,
                       parameters: HCILESetScanParameters = .init(),
                       timeout: HCICommandTimeout = .default,
                       shouldContinue: () -> (Bool),
                       foundDevice: (HCILEAdvertisingReport.Report) -> ()) throws {
        
        // macro for enabling / disabling scan
        func enableScan(_ isEnabled: Bool = true) throws {
            
            let scanEnableCommand = HCILESetScanEnable(isEnabled: isEnabled,
                                                       filterDuplicates: filterDuplicates)
            
            do { try deviceRequest(scanEnableCommand, timeout: timeout) }
            catch HCIError.commandDisallowed { /* ignore, means already turned on or off */ }
        }
        
        // disable scanning first
        try enableScan(false)
        
        // set parameters
        try deviceRequest(parameters, timeout: timeout)
        
        // enable scanning
        try enableScan()
        
        // disable scanning after completion
        defer { do { try enableScan(false) } catch { /* ignore all errors disabling scanning */ } }
        
        // poll for scanned devices
        try pollEvent(HCILowEnergyMetaEvent.self, shouldContinue: shouldContinue) { (metaEvent) in
            
            // only want advertising report
            guard metaEvent.subevent == .advertisingReport
                else { return }
            
            // parse LE advertising report
            guard let advertisingReport = HCILEAdvertisingReport(data: metaEvent.eventData)
                else { throw BluetoothHostControllerError.garbageResponse(Data(metaEvent.eventData).hexEncodedString()) }
            
            // call closure on each device found
            advertisingReport.reports.forEach { foundDevice($0) }
        }
    }
    
}

// MARK: - Command

/// LE Set Scan Enable Command
///
/// The `LE Set Scan Enable Command` command is used to start scanning.
/// Scanning is used to discover advertising devices nearby.
@frozen
public struct HCILESetScanEnable: HCICommandParameter { // HCI_LE_Set_Scan_Enable
    
    public static let command = HCILowEnergyCommand.setScanEnable // 0x000C
    public static let length = 2
    
    /// Whether scanning is enabled or disabled.
    public var isEnabled: Bool // LE_Scan_Enable
    
    /// Controls whether the Link Layer shall filter duplicate advertising reports to the Host,
    /// or if it shall generate advertising reports for each packet received.
    public var filterDuplicates: Bool // Filter_Duplicates
    
    /// Initialize a `LE Set Scan Enable Command` HCI command parameter.
    ///
    /// The `LE Set Scan Enable Command` command is used to start scanning.
    /// Scanning is used to discover advertising devices nearby.
    ///
    /// - Parameter enabled: Whether scanning is enabled or disabled.
    ///
    /// - Parameter filterDuplicates: Controls whether the Link Layer shall filter duplicate advertising
    /// reports to the Host, or if it shall generate advertising reports for each packet received.
    public init(isEnabled: Bool = false,
                filterDuplicates: Bool = false) {
        
        self.isEnabled = isEnabled
        self.filterDuplicates = filterDuplicates
    }
    
    public var data: Data {
        
        return Data([isEnabled.byteValue, filterDuplicates.byteValue])
    }
}
