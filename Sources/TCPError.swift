//
// Created by andyge on 16/1/3.
//

import Foundation
import CLibuv

public enum TCPError: ErrorType {
    case TCPSuccessed
    case TCPLoopInit(Int32)
    case TCPLoopRun(Int32)
    case TCPLoopNil
    case TCPServerIP4Addr(Int32)
    case TCPServerInit(Int32)
    case TCPServerBind(Int32)
    case TCPServerListen(Int32)
    case TCPServerHasListened
    case TCPServerAccept(Int32)
    case TCPServerNewClient(Int32)
    case TCPClientInit(Int32)
    case TCPClientNotInit
    case TCPClientPeerClosed
    case TCPClientRead(Int32)
    case TCPClientStartRead(Int32)
    case TCPClientStopRead(Int32)
    case TCPClientStartWrite(Int32)
    case TCPClientWrite(Int32)
}

extension TCPError: CustomStringConvertible {
    public var description: String {
        switch self {
            case TCPSuccessed:
                return "tcp op successed"
            case TCPLoopInit(let err):
                return "uv_loop_init err: \(uv_strerror(err))"
            case TCPLoopRun(let err):
                return "uv_loop_run err: \(uv_strerror(err))"
            case TCPLoopNil:
                return "uv_loop_t loop nil"
            case TCPServerIP4Addr(let err):
                return "uv_ip4_addr err: \(uv_strerror(err))"
            case TCPServerInit(let err):
                return "tcpserver uv_tcp_init err: \(uv_strerror(err))"
            case TCPServerBind(let err):
                return "tcpserver uv_tcp_bind err: \(uv_strerror(err))"
            case TCPServerListen(let err):
                return "tcpserver uv_listen err: \(uv_strerror(err))"
            case TCPServerHasListened:
                return "tcpserver has listened again"
            case TCPServerAccept(let err):
                return "tcpserver uv_accept err: \(uv_strerror(err))"
            case TCPServerNewClient(let err):
                return "tcpserver onNewConnect err: \(uv_strerror(err))"
            case TCPClientInit(let err):
                return "tcpclient uv_tcp_init err: \(uv_strerror(err))"
            case TCPClientNotInit:
                return "tcpclient has not inited"
            case TCPClientPeerClosed:
                return "tcpclient closed by remote peer"
            case TCPClientRead(let err):
                return "tcpclient read err: \(uv_strerror(err))"
            case TCPClientStartRead(let err):
                return "tcpclient startread err: \(uv_strerror(err))"
            case TCPClientStopRead(let err):
                return "tcpclient stopread err: \(uv_strerror(err))"
            case TCPClientStartWrite(let err):
                return "tcpclient uv_write err: \(uv_strerror(err))"
            case TCPClientWrite(let err):
                return "tcpclient uv_write_cb err: \(uv_strerror(err))"
        }
    }
}
