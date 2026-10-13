// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GymCoachKit",
    platforms: [.iOS(.v17), .watchOS(.v10), .macOS(.v14)],
    products: [
        .library(name: "GymCoachKit", targets: ["GymCoachKit"]),
    ],
    targets: [
        .target(name: "GymCoachKit"),
        .testTarget(name: "GymCoachKitTests", dependencies: ["GymCoachKit"]),
    ]
)
