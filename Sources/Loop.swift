//
// Created by andyge on 15/12/28.
//

import CLibuv

public protocol TCPDelegate {
    func onTCPServerNewClient(server: TCPServer, err: TCPError?)
    func onTCPClientRecved(client: TCPClient)
    func onTCPClientError(client: TCPClient, err: TCPError)
    func onTCPClientSendOut(client: TCPClient)
    func onTCPClientConnected(client: TCPClient, err: TCPError?)
}

public class Loop {
    var loop: UnsafeMutablePointer<uv_loop_t> = nil
    var delegate: TCPDelegate

    public init(_ delegate: TCPDelegate) {
        loop = UnsafeMutablePointer<uv_loop_t>.alloc(1);
        let ret = uv_loop_init(loop)
        if ret != 0 {
            fatalError("loop init failed err: \(uv_strerror(ret))")
        }
        self.delegate = delegate
    }

    deinit {
        if loop != nil {
            uv_loop_close(loop)
            loop.dealloc(1)
            loop = nil
        }
    }

    public func run() throws {
        let ret = uv_run(loop, UV_RUN_DEFAULT)
        if ret != 0 {
            throw TCPError.TCPLoopRun(ret)
        }
    }

    public func stop() throws {
        if loop == nil {
            throw TCPError.TCPLoopNil
        }
        uv_stop(loop)
    }
}
