//
//  UUID.swift
//  
//
//  Created by Alsey Coleman Miller on 1/7/21.
//

import Foundation
import CoreFoundation
import Bluetooth

@_silgen_name("BTUUIDCreateWithCString")
public func BTUUIDCreateWithCString(_ cString: UnsafePointer<CChar>?) -> BluetoothUUID {
    return cString
        .flatMap { String(cString: $0) }
        .flatMap { BluetoothUUID(rawValue: $0) } ?? .bit128(.zero)
}

@_silgen_name("BTUUIDCreateWithString")
public func BTUUIDCreateWithString(_ string: CFString?) -> BluetoothUUID {
    guard let string = string else {
        return .bit128(.zero)
    }
    return BluetoothUUID(rawValue: String(unsafeBitCast(string, to: NSString.self))) ?? .bit128(.zero)
}

@_silgen_name("BTUUIDByteSwap")
public func BTUUIDByteSwap(_ pointer: UnsafeMutablePointer<BluetoothUUID>?) {
    guard let pointer = pointer else {
        assertionFailure("Nil pointer")
        return
    }
    pointer.pointee = pointer.pointee.byteSwapped
}
