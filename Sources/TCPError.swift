//
// Created by andyge on 16/1/3.
//

import Foundation
import CLibuv

public enum TCPError: ErrorType {
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
    case TCPClientStartConnect(Int32)
    case TCPClientConnecting
    case TCPClientConnect(Int32)
}

func getUVErrorStr(err: Int32) -> String {
    let cstr = uv_strerror(err)
    if let str = String.fromCString(cstr) {
        return str
    } else {
        return "unkown err(\(err))"
    }
}

extension TCPError: CustomStringConvertible {
    public var description: String {
        switch self {
            case TCPLoopInit(let err):
                return "uv_loop_init err: \(getUVErrorStr(err))"
            case TCPLoopRun(let err):
                return "uv_loop_run err: \(getUVErrorStr(err))"
            case TCPLoopNil:
                return "uv_loop_t loop nil"
            case TCPServerIP4Addr(let err):
                return "uv_ip4_addr err: \(getUVErrorStr(err))"
            case TCPServerInit(let err):
                return "tcpserver uv_tcp_init err: \(getUVErrorStr(err))"
            case TCPServerBind(let err):
                return "tcpserver uv_tcp_bind err: \(getUVErrorStr(err))"
            case TCPServerListen(let err):
                return "tcpserver uv_listen err: \(getUVErrorStr(err))"
            case TCPServerHasListened:
                return "tcpserver has listened again"
            case TCPServerAccept(let err):
                return "tcpserver uv_accept err: \(getUVErrorStr(err))"
            case TCPServerNewClient(let err):
                return "tcpserver onNewConnect err: \(getUVErrorStr(err))"
            case TCPClientInit(let err):
                return "tcpclient uv_tcp_init err: \(getUVErrorStr(err))"
            case TCPClientNotInit:
                return "tcpclient has not inited"
            case TCPClientPeerClosed:
                return "tcpclient closed by remote peer"
            case TCPClientRead(let err):
                return "tcpclient read err: \(getUVErrorStr(err))"
            case TCPClientStartRead(let err):
                return "tcpclient startread err: \(getUVErrorStr(err))"
            case TCPClientStopRead(let err):
                return "tcpclient stopread err: \(getUVErrorStr(err))"
            case TCPClientStartWrite(let err):
                return "tcpclient uv_write err: \(getUVErrorStr(err))"
            case TCPClientWrite(let err):
                return "tcpclient uv_write_cb err: \(getUVErrorStr(err))"
            case TCPClientStartConnect(let err):
                return "tcpclient uv_connect err: \(getUVErrorStr(err))"
            case TCPClientConnecting:
                return "tcpclient in connecting"
            case TCPClientConnect(let err):
                return "tcpclient uv_connect_cb err: \(getUVErrorStr(err))"
        }
    }
}
