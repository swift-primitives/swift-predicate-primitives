// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-predicate-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Predicate Primitives",
            targets: ["Predicate Primitives"]
        )
    ],
    dependencies: [
        .package(path: "../swift-logic-primitives")
    ],
    targets: [
        .target(
            name: "Predicate Primitives",
            dependencies: [
                .product(name: "Logic Ternary Primitives", package: "swift-logic-primitives")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety()
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
