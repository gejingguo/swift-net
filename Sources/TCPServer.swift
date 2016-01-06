//
// Created by andyge on 15/12/28.
//

import Foundation
import CLibuv
//import Loop

func onTCPServerNewConnection(req: UnsafeMutablePointer<uv_stream_t>, status: Int32) {
    let err = status == 0 ? TCPError.TCPSuccessed : TCPError.TCPServerNewClient(status)
    let ptr = req.memory.data

    if let server = unsafeBitCast(ptr, TCPServerHandle.self).server {
        server.loop?.delegate.onTCPServerNewClient(server, err: err)
    }
}

class TCPServerHandle {
    weak var server: TCPServer? = nil
}

public class TCPServer {
    weak var loop: Loop? = nil
    var server: UnsafeMutablePointer<uv_tcp_t> = nil
    var flag: Int = 0
    var handle: TCPServerHandle

    public init(loop: Loop) {
        self.loop = loop
        handle = TCPServerHandle()
        handle.server = self
    }

    deinit {
        if server != nil {
            uv_close(UnsafeMutablePointer<uv_handle_t>(server), nil)
            server.dealloc(1)
            server = nil
        }
    }

    public func listen(host: String, port: Int32) throws {
        if loop == nil || loop?.loop == nil {
            throw TCPError.TCPLoopNil
        }
        if server != nil {
            throw TCPError.TCPServerHasListened
        }

        server = UnsafeMutablePointer<uv_tcp_t>.alloc(1)

        let addr = UnsafeMutablePointer<sockaddr_in>.alloc(1)
        defer { addr.dealloc(1) }

        var ret = host.withCString { (cstr) -> Int32 in
            return uv_ip4_addr(cstr, port, addr)
        }
        if ret != 0 {
            throw TCPError.TCPServerIP4Addr(ret)
        }
        ret = uv_tcp_init(loop!.loop, server)
        if ret != 0 {
            throw TCPError.TCPServerInit(ret)
        }
        ret = uv_tcp_bind(server, UnsafePointer<sockaddr>(addr), 0)
        if ret != 0 {
            throw TCPError.TCPServerBind(ret)
        }
        ret = uv_listen(UnsafeMutablePointer<uv_stream_t>(server), 128, onTCPServerNewConnection)
        if ret != 0 {
            throw TCPError.TCPServerListen(ret)
        }

        let ptr = unsafeAddressOf(handle)
        server.memory.data = unsafeBitCast(ptr, UnsafeMutablePointer<Void>.self)
        print("tcp server init ..")
    }

    public func listen(port: Int32) throws {
        return try listen("0.0.0.0", port: port)
    }

    public func test() {
        print("hello test.")
    }

    public func accept(client: TCPClient) throws {
        let ret = uv_accept(UnsafeMutablePointer<uv_stream_t>(server), UnsafeMutablePointer<uv_stream_t>(client.client))
        if ret != 0 {
            throw TCPError.TCPServerAccept(ret)
        }
        client.connected = true
        // 设置开始读
        try client.startRead()
    }
}
