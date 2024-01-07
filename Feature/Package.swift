// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let coreDependencies: [PackageDescription.Target.Dependency] = [
    .product(name: "Core", package: "Core"),
    .product(name: "UIComponents", package: "UIComponents"),
]

let package = Package(
    name: "Feature",
    platforms: [.iOS(.v16), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "Root",targets: ["Root"]),
        .library(name: "AccountBookList",targets: ["AccountBookList"]),
        .library(name: "Setting",targets: ["Setting"]),
        .library(name: "Billslist",targets: ["Billslist"]),
        .library(name: "BillDetail",targets: ["BillDetail"]),
        .library(name: "AccountBookConfig",targets: ["AccountBookConfig"]),
        .library(name: "ParticipatorDetail", targets: ["ParticipatorDetail"]),
        .library(name: "InputAccounts", targets: ["InputAccounts"]),
        .library(name: "Categories", targets: ["Categories"]),
        .library(name: "SubCategories", targets: ["SubCategories"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Core", path: "../Core"),
        .package(name: "UIComponents", path: "../UIComponents"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Root",
            dependencies: coreDependencies + [
                "AccountBookList",
                "Billslist",
            ]),
        .testTarget(
            name: "RootTests",
            dependencies: ["Root"]),
        .target(name: "AccountBookList",
               dependencies: coreDependencies + [
                "AccountBookConfig",
               ]),
        .target(name: "Setting",
               dependencies: coreDependencies + [
                "AccountBookList",
               ]
               ),
        .target(name: "Billslist",
               dependencies:coreDependencies + [
                    "BillDetail",
                    "Setting",
                    "InputAccounts",
               ]
               ),
        .target(name: "AccountBookConfig",
               dependencies:coreDependencies + [
                "ParticipatorDetail",
               ]
               ),
        .target(name: "ParticipatorDetail",
               dependencies:coreDependencies
               ),
        .target(name: "BillDetail",
               dependencies:coreDependencies
               ),
        .target(name: "InputAccounts",
               dependencies:coreDependencies + [
                "Categories",
                "SubCategories",
               ]),
        .target(name: "Categories",
               dependencies:coreDependencies
               ),
        .target(name: "SubCategories",
               dependencies:coreDependencies
               ),
    ]
)
