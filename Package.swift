// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Synesthesia",
    platforms: [.iOS(.v26), .macOS(.v26)],
    targets: [
        .target(
            name: "Synesthesia",
            path: "Synesthesia"
        ),
    ]
)
