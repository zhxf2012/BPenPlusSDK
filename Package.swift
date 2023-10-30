// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BPenPlusSDKSPM",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BPenPlusSDKSPM",
           // type: .dynamic,
            targets: ["BPenPlusSDKSPM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/zhxf2012/BPBleOTA", from: "0.6.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        
        .target(
                    name: "BPenPlusSDKSPM",
                    dependencies: ["BPenPlusSDK",
                                   .product(name: "BPBleOTA",package: "BPBleOTA")]
                ),
        .binaryTarget(
            name: "BPenPlusSDK",
            path: "BPenPlusSDK/BPenPlusSDK.xcframework"
        ),
        .testTarget(
            name: "BPenPlusSDKSPMTests",
            dependencies: ["BPenPlusSDKSPM"]),
    ],
    swiftLanguageVersions: [.v5]
)
