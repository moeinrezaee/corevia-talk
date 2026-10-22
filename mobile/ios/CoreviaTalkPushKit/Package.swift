// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CoreviaTalkPushKit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "CoreviaTalkPushKit", targets: ["CoreviaTalkPushKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/swhitty/SwiftDraw.git", exact: "0.29.0")
    ],
    targets: [
        .target(
            name: "CSecp256k1",
            sources: ["vendor/src/secp256k1.c", "vendor/src/precomputed_ecmult.c", "vendor/src/precomputed_ecmult_gen.c"],
            publicHeadersPath: "include",
            cSettings: [.define("ENABLE_MODULE_EXTRAKEYS"), .define("ENABLE_MODULE_SCHNORRSIG")]
        ),
        .target(
            name: "CoreviaTalkPushKit",
            dependencies: ["CSecp256k1", .product(name: "SwiftDraw", package: "SwiftDraw")]
        ),
        .testTarget(
            name: "CoreviaTalkPushKitTests",
            dependencies: [
                "CoreviaTalkPushKit",
                "CSecp256k1",
            ],
            resources: [.copy("Fixtures/app_attest_transcripts.json"), .copy("CryptoFixtures/bip340.csv")]
        ),
    ]
)
