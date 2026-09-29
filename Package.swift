// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-predicate",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Predicate", targets: ["Predicate"]),
    ],
    traits: [
        .trait(name: "Logic", description: "Ternary evaluation of optional inputs"),
        .trait(name: "Contramap", description: "Borrowed input adaptation"),
        .trait(name: "Always", description: "Constant predicates"),
        .trait(name: "Optic", description: "Borrowed focus evaluation"),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-logic.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-contramap.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-always.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-optic.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Predicate",
            dependencies: [
                .product(name: "Logic", package: "swift-logic", condition: .when(traits: ["Logic"])),
                .product(name: "Contramap", package: "swift-contramap", condition: .when(traits: ["Contramap"])),
                .product(name: "Always", package: "swift-always", condition: .when(traits: ["Always"])),
                .product(name: "Optic", package: "swift-optic", condition: .when(traits: ["Optic"])),
            ]
        ),
        .testTarget(
            name: "Predicate Tests",
            dependencies: [
                .target(name: "Predicate"),
            ]
        ),
        .testTarget(
            name: "Always Predicate Tests",
            dependencies: [.target(name: "Predicate")]
        ),
        .testTarget(
            name: "Contramap Predicate Tests",
            dependencies: [.target(name: "Predicate")]
        ),
        .testTarget(
            name: "Optic Predicate Tests",
            dependencies: [.target(name: "Predicate")]
        ),
        .testTarget(
            name: "Swift Predicate Tests",
            dependencies: [.target(name: "Predicate")]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("Lifetimes"),
        .treatAllWarnings(as: .error),
    ]
}
