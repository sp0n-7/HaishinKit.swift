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
    name: "HaishinKit202",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .visionOS(.v1),
        .macOS(.v10_15),
        .macCatalyst(.v14)
    ],
    products: [
        .library(name: "HaishinKit202", targets: ["HaishinKit202"]),
        .library(name: "SRTHaishinKit202", targets: ["SRTHaishinKit202"]),
        .library(name: "MoQTHaishinKit202", targets: ["MoQTHaishinKit202"])
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
            name: "HaishinKit202",
            dependencies: ["Logboard"],
            path: "HaishinKit/Sources",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SRTHaishinKit202",
            dependencies: ["libsrt", "HaishinKit202"],
            path: "SRTHaishinKit/Sources",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "MoQTHaishinKit202",
            dependencies: ["HaishinKit202"],
            path: "MoQTHaishinKit/Sources",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "HaishinKitTests202",
            dependencies: ["HaishinKit202"],
            path: "HaishinKit/Tests",
            resources: [
                .process("Asset")
            ],
            swiftSettings: swiftSettings
        )
    ],
    swiftLanguageModes: [.v6, .v5]
)
