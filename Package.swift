// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Synesthesia",
    platforms: [.iOS(.v17), .macOS(.v14)],
    targets: [
        .target(
            name: "Synesthesia",
            path: "Synesthesia"
        ),
    ]
)
