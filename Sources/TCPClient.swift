//
// Created by andyge on 15/12/28.
//

import Foundation
import CLibuv


class TCPClientHandle {
    weak var client: TCPClient? = nil
}

public class TCPClient {
    var loop: Loop? = nil
    var client: UnsafeMutablePointer<uv_tcp_t> = nil
    var writeReq: UnsafeMutablePointer<uv_write_t> = nil
    var readBuff: TCPBuffer
    var writeBuff: TCPBuffer
    var writeingPktCount = 0
    var index = -1
    private var handle: TCPClientHandle
    public var flag: Int = 0
    public var connected: Bool = false
    public var peerAddr: String = ""


    public init() {
        client = UnsafeMutablePointer<uv_tcp_t>.alloc(1)
        writeReq = UnsafeMutablePointer<uv_write_t>.alloc(1)
        readBuff = TCPBuffer(0, pktCount: 1)
        writeBuff = TCPBuffer(0, pktCount: 0)
        handle = TCPClientHandle()
        print("tcpclient created...")
    }

    deinit {
        destroy()
        if client != nil {
            client.dealloc(1)
        }
        if writeReq != nil {
            writeReq.dealloc(1)
        }
    }

    func initWithLoop(loop: Loop) throws {
        if self.loop != nil {
            destroy()
        }
        self.loop = loop
        self.handle.client = self
        let ret = uv_tcp_init(loop.loop, client)
        if ret != 0 {
            destroy()
            //fatalError("tcpclient uv_tcp_init failed, err: \(uv_strerror(ret))")
            throw TCPError.TCPClientInit(ret)
        }
    }

    func destroy() {
        if loop != nil {
            uv_close(UnsafeMutablePointer<uv_handle_t>(client), nil)
            loop = nil
        }
        self.flag = 0
        self.readBuff.clear()
        self.writeBuff.clear()
        self.writeingPktCount = 0
        self.connected = false
        self.peerAddr = ""
    }

    func getPeerAddr() {
        if !self.connected {
            return
        }
        let addr = UnsafeMutablePointer<sockaddr>.alloc(1)
        //addr.initialize(0)
        defer { addr.dealloc(1)}
        var len: Int32 = (Int32)(sizeof(sockaddr.self))
        var ret = uv_tcp_getpeername(client, addr, &len)
        if ret != 0 {
            return
        }
        let slen = 32
        let addrStr = UnsafeMutablePointer<CChar>.alloc(slen)
        //addrStr.initialize(0)
        defer { addrStr.dealloc(slen) }
        ret = uv_ip4_name(UnsafeMutablePointer<sockaddr_in>(addr), addrStr, slen)
        if ret != 0 {
            return
        }
        self.peerAddr = String.fromCString(addrStr) ?? ""
    }

    public func connect() throws {

    }

    func startRead() throws {
        if self.loop == nil {
            throw TCPError.TCPClientNotInit
        }
        //handle = TCPClientHandle(self)
        //handle.client = self
        let ptr = unsafeAddressOf(handle)
        client.memory.data = unsafeBitCast(ptr, UnsafeMutablePointer<Void>.self)
        let ret = uv_read_start(UnsafeMutablePointer<uv_stream_t>(self.client), onTCPClientAllocBuffer, onTCPClientRead)
        if ret != 0 {
            throw TCPError.TCPClientStartRead(ret)
        }
    }

    func stopRead() throws {
        if self.loop == nil {
            throw TCPError.TCPClientNotInit
        }
        let ret = uv_read_stop(UnsafeMutablePointer<uv_stream_t>(self.client))
        if ret != 0 {
            throw TCPError.TCPClientStopRead(ret)
        }
    }

    func startWrite() throws {
        if self.loop == nil {
            throw TCPError.TCPClientNotInit
        }
        let pkts = writeBuff.getReadPkts()
        if pkts.isEmpty {
            return
        }
        if self.writeingPktCount > 0 {
            return
        }

        let ptr = unsafeAddressOf(handle)
        writeReq.memory.data = unsafeBitCast(ptr, UnsafeMutablePointer<Void>.self)

        let bufReq = UnsafeMutablePointer<uv_buf_t>.alloc(pkts.count)
        defer { bufReq.dealloc(pkts.count) }
        var req = bufReq
        for pkt in pkts {
            req.memory.base = pkt.readAddr
            req.memory.len = pkt.size
            req = req.successor()
        }

        let bufCount: UInt32 = (UInt32)(pkts.count)
        let ret = uv_write(writeReq, UnsafeMutablePointer<uv_stream_t>(self.client), bufReq, bufCount, onTCPClientWrite)
        if ret != 0 {
            throw TCPError.TCPClientStartWrite(ret)
        }
        self.writeingPktCount = pkts.count
    }

    public func send(buff: TCPBuffer) throws {
        self.writeBuff.append(buff)
        try self.startWrite()
    }

    public func getReadBuffer(n: Int) -> TCPBuffer? {
        return self.readBuff.getBuffer(n)
    }

    public func getReadSize() -> Int {
        return self.readBuff.size
    }
}

func onTCPClientAllocBuffer(req: UnsafeMutablePointer<uv_handle_t>, suggestSize: Int, buf: UnsafeMutablePointer<uv_buf_t>) {
    print("onTCPClientAllocBuffer")
    //let err = status == 0 ? TCPError.TCPSuccessed : TCPError.TCPServerNewClient(status)
    let ptr = req.memory.data
    if let client = unsafeBitCast(ptr, TCPClientHandle.self).client {
        if client.readBuff.pkts.isEmpty {
            client.readBuff.allocPkt(1)
        }
        if let pkt = client.readBuff.getCurWritePkt() {
            buf.memory.base = pkt.writeAddr
            buf.memory.len = pkt.space
        }
    }
}

func onTCPClientRead(req: UnsafeMutablePointer<uv_stream_t>, read: Int, buf: UnsafePointer<uv_buf_t>) {
    print("onTCPClientRead read:\(read)")
    let ptr = req.memory.data
    if let client = unsafeBitCast(ptr, TCPClientHandle.self).client {
        if read < 0 {
            var err = TCPError.TCPClientRead((Int32)(read))
            if (Int32)(read) == UV_EOF.rawValue {
                err = TCPError.TCPClientPeerClosed
            }
            client.loop?.delegate.onTCPClientError(client, err: err)
            //
            client.destroy()
            return
        }
        if let pkt = client.readBuff.getCurWritePkt() {
            pkt.write += read
        }
        client.loop?.delegate.onTCPClientRecved(client)
    }
}

func onTCPClientWrite(req: UnsafeMutablePointer<uv_write_t>, ret: Int32) {
    let ptr = req.memory.data
    if let client = unsafeBitCast(ptr, TCPClientHandle.self).client {
        if ret != 0 {
            client.loop?.delegate.onTCPClientError(client, err: TCPError.TCPClientWrite(ret))
            client.destroy()
            return
        }
        for _ in 0 ..< client.writeingPktCount {
            client.writeBuff.pkts.removeAtIndex(0)
        }

        client.writeingPktCount = 0
        if !client.writeBuff.pkts.isEmpty {
            do {
                try client.startWrite()
            } catch {
                client.loop?.delegate.onTCPClientError(client, err: error as! TCPError)
                client.destroy()
            }
        }
        print("write over..")
    }
}