// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

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
        .library(name: "SRTHaishinKit194", targets: ["SRTHaishinKit194"])
    ],
    dependencies: [
        .package(url: "https://github.com/shogo4405/Logboard.git", exact: "2.4.1")
    ],
    targets: [
        .binaryTarget(
            name: "libsrt",
            path: "Vendor/SRT/libsrt.xcframework"
        ),
        .target(name: "SwiftPMSupport194"),
        .target(name: "HaishinKit194",
                dependencies: ["Logboard", "SwiftPMSupport194"],
                path: "Sources",
                sources: [
                    "Codec",
                    "Extension",
                    "IO",
                    "ISO",
                    "Net",
                    "RTMP",
                    "Screen",
                    "Util"
                ]),
        .target(name: "SRTHaishinKit194",
                dependencies: [
                    "libsrt",
                    "HaishinKit194"
                ],
                path: "SRTHaishinKit"
        )
    ]
)
