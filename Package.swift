// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

#if swift(<6)
let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("ExistentialAny"),
    .enableExperimentalFeature("StrictConcurrency")
]
#else
let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny")
]
#endif

let package = Package(
    name: "HaishinKit194",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .visionOS(.v1),
        .macOS(.v10_15),
        .macCatalyst(.v14)
    ],
    products: [
        .library(name: "HaishinKit194", targets: ["HaishinKit194"]),
        .library(name: "SRTHaishinKit194", targets: ["SRTHaishinKit194"]),
        .library(name: "MoQTHaishinKit194", targets: ["MoQTHaishinKit194"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3"),
        .package(url: "https://github.com/shogo4405/Logboard.git", "2.5.0"..<"2.6.0")
    ],
    targets: [
        .binaryTarget(
            name: "libsrt",
            path: "SRTHaishinKit/Vendor/SRT/libsrt.xcframework"
        ),
        .target(
            name: "HaishinKit194",
            dependencies: ["Logboard"],
            path: "HaishinKit/Sources",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SRTHaishinKit194",
            dependencies: ["libsrt", "HaishinKit194"],
            path: "SRTHaishinKit/Sources",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "MoQTHaishinKit194",
            dependencies: ["HaishinKit194"],
            path: "MoQTHaishinKit/Sources",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "HaishinKitTests194",
            dependencies: ["HaishinKit194"],
            path: "HaishinKit/Tests",
            resources: [
                .process("Asset")
            ],
            swiftSettings: swiftSettings
        )
    ],
    swiftLanguageModes: [.v6, .v5]
)
