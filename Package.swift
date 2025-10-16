// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "SnackRadar",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SnackRadar",
            targets: ["SnackRadar"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "10.0.0"
        )
    ],
    targets: [
        .target(
            name: "SnackRadar",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk")
            ],
            path: "SnackRadar"
        )
    ]
)
