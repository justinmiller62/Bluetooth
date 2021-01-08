// swift-tools-version:5.1
import PackageDescription

#if os(Linux)
let libraryType: PackageDescription.Product.Library.LibraryType = .dynamic
#else
let libraryType: PackageDescription.Product.Library.LibraryType = .static
#endif

let package = Package(
    name: "Bluetooth",
    products: [
        .library(
            name: "Bluetooth",
            type: libraryType,
            targets: [
                "Bluetooth",
                "BluetoothGAP",
                "BluetoothGATT",
                "BluetoothHCI"
            ]
        )
    ],
    targets: [
        .target(
            name: "Bluetooth"
        ),
        .target(
            name: "BluetoothGAP",
            dependencies: [
                "Bluetooth"
            ]
        ),
        .target(
            name: "BluetoothGATT",
            dependencies: [
                "Bluetooth",
            ]
        ),
        .target(
            name: "BluetoothHCI",
            dependencies: [
                "Bluetooth",
                "BluetoothGAP"
            ]
        ),
        .target(
            name: "CBluetooth",
            dependencies: [
                "Bluetooth"
            ]
        ),
        .testTarget(
            name: "BluetoothTests",
            dependencies: [
                "Bluetooth",
                "BluetoothGAP",
                "BluetoothGATT",
                "BluetoothHCI"
            ]
        )
    ]
)
