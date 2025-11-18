// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DietSolver",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DietSolver",
            targets: ["DietSolver"]),
        .executable(
            name: "DietSolverApp",
            targets: ["DietSolverApp"]),
    ],
    dependencies: [
        // Testing frameworks
    ],
    targets: [
        .target(
            name: "DietSolver",
            dependencies: [],
            path: "Sources/DietSolver"),
        .executableTarget(
            name: "DietSolverApp",
            dependencies: ["DietSolver"],
            path: "Sources/DietSolverApp"),
        .testTarget(
            name: "DietSolverTests",
            dependencies: ["DietSolver"],
            path: "Tests/DietSolverTests"),
    ]
)
