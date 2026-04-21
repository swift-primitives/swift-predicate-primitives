// swift-tools-version: 6.3.1

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
        .package(path: "../swift-logic-primitives"),
        .package(path: "../swift-witness-primitives"),
    ],
    targets: [
        .target(
            name: "Predicate Primitives",
            dependencies: [
                .product(name: "Logic Ternary Primitives", package: "swift-logic-primitives"),
                .product(name: "Witness Primitives", package: "swift-witness-primitives"),
            ]
        ),
        .testTarget(
            name: "Predicate Primitives Tests",
            dependencies: [
                "Predicate Primitives",
                .product(name: "Logic Ternary Primitives", package: "swift-logic-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
