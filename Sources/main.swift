//
// Created by andyge on 15/12/28.
//

import Foundation
//import SwiftUV


class TCPHandler: TCPDelegate {
    var clientMgr: TCPClientMgr
    //weak var server: TCPServer

    init() {
        clientMgr = TCPClientMgr(add: 10, capacity: 100)
        //self.server = server
    }

    func onTCPServerNewClient(server: TCPServer, err: TCPError) {
        print("tcpserver onnewclient...")
        var client: TCPClient? = nil
        do {
            client = try clientMgr.alloc(server.loop!)
            if client == nil {
                print("client alloc failed.")
                return
            }
            try server.accept(client!)
            client!.flag = server.flag

            print("accept new client")
        } catch {
            print("ontcpnew err: \(error)")
            if client != nil {
                clientMgr.free(client!)
            }
        }
    }

    func onTCPClientRecved(client: TCPClient) {
        print("recv data: \(client.getReadSize()),\(client.readBuff.description)")
        guard let buf = client.getReadBuffer(client.getReadSize()) else {
            return
        }
        print("readbuff data: \(client.getReadSize()),\(client.readBuff.description)")
        do {
            try client.send(buf)
            print("writebuff data: \(client.writeBuff.description)")
        } catch {
            self.onTCPClientError(client, err: error as! TCPError)
        }
    }

    func onTCPClientError(client: TCPClient, err: TCPError) {
        print("onTCPClientError err: \(err)")
        clientMgr.free(client)
    }

    func onTCPClientSendOut(client: TCPClient) {

    }
}

do {
    print("hello world!")
    var loop = Loop(TCPHandler())
    //loop.test()

    var server = TCPServer(loop: loop)
    try server.listen(8999)

    print("before run.")
    try loop.run()
    print("after run.")

} catch {
    print("err:\(error)")
}

