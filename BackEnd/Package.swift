// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "BackEnd",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/zonble/CurlDSL.git", branch: "master"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [.product(name: "Vapor", package: "vapor"),
                           .product(name: "CurlDSL", package: "CurlDSL"),
                           .product(name: "Fluent", package: "fluent"),
                           .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
                          ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: [.target(name: "App")]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [.target(name: "App"), .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
