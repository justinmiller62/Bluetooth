//
//  Address.swift
//  
//
//  Created by Alsey Coleman Miller on 1/7/21.
//

import Foundation
import CoreFoundation
import Bluetooth

@_silgen_name("BTAddressCreateWithCString")
public func BTAddressCreateWithCString(_ cString: UnsafePointer<CChar>?) -> BluetoothAddress {
    return cString
        .flatMap { String(cString: $0) }
        .flatMap { BluetoothAddress(rawValue: $0) } ?? .zero
}

@_silgen_name("BTAddressCreateWithString")
public func BTAddressCreateWithString(_ string: CFString?) -> BluetoothAddress {
    guard let string = string else {
        return .zero
    }
    return BluetoothAddress(rawValue: String(unsafeBitCast(string, to: NSString.self))) ?? .zero
}

@_silgen_name("BTAddressByteSwap")
public func BTAddressByteSwap(_ pointer: UnsafeMutablePointer<BluetoothAddress>?) {
    guard let pointer = pointer else {
        assertionFailure("Nil pointer")
        return
    }
    pointer.pointee = pointer.pointee.byteSwapped
}
