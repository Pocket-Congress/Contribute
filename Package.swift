// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pocket Congress Contributions",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SampleContribution",
            targets: ["SampleContribution"]),
    ],
    dependencies: [
			
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SampleContribution", dependencies: [], path: "SampleContribution/Sources/SampleContribution"),
        .testTarget(
            name: "SampleContributionTests",
            dependencies: ["SampleContribution"], path: "SampleContribution/Tests/SampleContributionTests"),
    ]
)
