//
// Created by andyge on 15/12/28.
//

import PackageDescription

let package = Package(
name: "swift-test",
        targets: [],
        dependencies: [
                .Package(url: "../CLibuv", majorVersion: 1),
		    //.Package(url: "../swift-uv", majorVersion: 1),
        ]
)
