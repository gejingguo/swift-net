//
// Created by andyge on 16/1/4.
//

import Foundation

class TCPClientMgr {
    private var client: [TCPClient]
    private var capacity = 0
    private var add = 0
    private var free: [Int]

    init(add: Int, capacity: Int) {
        self.capacity = capacity
        self.add = add
        self.client = []
        self.free = []
    }

    deinit {

    }

    func alloc(loop: Loop) throws -> TCPClient?  {
        if client.count >= self.capacity {
            return nil
        }

        if let index = free.popLast() {
            try client[index].initWithLoop(loop)
            return client[index]
        }

        let cli = TCPClient()
        try cli.initWithLoop(loop)
        cli.index = client.count

        //free.append(cli.index)
        client.append(cli)

        return cli
    }

    func free(cli: TCPClient) {
        cli.destroy()
        free.append(cli.index)
    }
}
