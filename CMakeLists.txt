cmake_minimum_required(VERSION 3.4)
project(swift_test)

add_custom_target(swift_test
        COMMAND /Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/swift build
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        SOURCES Package.swift Sources/main.swift Sources/Loop.swift Sources/TCPError.swift Sources/TCPServer.swift Sources/TCPClient.swift Sources/TCPBuffer.swift Sources/TCPClientMgr.swift)