//
// Created by andyge on 16/1/3.
//

import Foundation
#if os(Linux)
import Glibc
#elseif os(OSX)
import Darwin
#endif

class TCPPkt: CustomStringConvertible {
    var data: UnsafeMutablePointer<CChar> = nil
    var read: Int = 0
    var write: Int = 0
    var capacity: Int = 0

    init(_ capacity: Int) {
        self.capacity = capacity;
        data = UnsafeMutablePointer<CChar>.alloc(self.capacity+1)
        data.initialize(0)
        print("tcppkt init ...")
    }

    deinit {
        if(data != nil) {
            data.dealloc(self.capacity+1)
        }
    }

    var readAddr: UnsafeMutablePointer<CChar> {
        return data.advancedBy(read)
    }
    var size: Int {
        return write - read
    }
    var writeAddr: UnsafeMutablePointer<CChar> {
        return data.advancedBy(write)
    }
    var space: Int {
        return (capacity - write)
    }

    func clear() {
        read = 0
        write = 0
    }

    var description: String {
        // 保证0结束
        data.advancedBy(write).memory = 0
        if let str = String.fromCString(readAddr) {
            return "pkt(read:\(read), write:\(write), data:\(str)"
        }
        return "pkt(read:\(read), write:\(write), data:"
    }
}

public class TCPBuffer: CustomStringConvertible {
    var pktLen: Int = 0
    static let MIN_PKT_SIZE: Int = 12
    var pkts: [TCPPkt] = []

    init(_ pktLen: Int, pktCount: Int) {
        self.pktLen = (pktLen > TCPBuffer.MIN_PKT_SIZE ? pktLen : TCPBuffer.MIN_PKT_SIZE)
        self.allocPkt(pktCount)
    }

    deinit {

    }

    func allocPkt(n: Int) {
        for _ in 0 ..< n {
            let pkt = TCPPkt(pktLen)
            pkts.append(pkt)
        }
    }

    var size: Int {
        var rsize = 0
        for pkt in pkts {
            rsize += pkt.size
        }
        return rsize
    }

    func getBuffer(n: Int) -> TCPBuffer? {
        if size < n {
            return nil
        }

        let buf = TCPBuffer(self.pktLen, pktCount: 0)
        var count = 0
        var left = n
        for i in 0 ..< pkts.count {
            let pkt = pkts[i]
            if pkt.size < left {
                buf.pkts.append(pkt)
                left -= pkt.size
            } else if pkt.size == left {
                buf.pkts.append(pkt)
                left = 0
                count = i + 1
                break
            } else {
                let npkt = TCPPkt(self.pktLen)
                // 拷贝left字节
                memcpy(npkt.writeAddr, pkt.readAddr, left)
                pkt.read += left
                npkt.write += left
                left = 0
                count = i
                break
            }
        }
        if count > 0 {
            if count == pkts.count {
                pkts.removeAll(keepCapacity: true)
            } else {
                for _ in 0 ..< count {
                    pkts.removeAtIndex(0)
                    //pkts.popFirst()
                }
            }
        }
        return buf
    }

    func append(buf: TCPBuffer) {
        for pkt in buf.pkts {
            pkts.append(pkt)
        }
        buf.pkts.removeAll(keepCapacity: true)
    }

    func clear() {
        for pkt in pkts {
            pkt.clear()
        }
    }

    func getCurWritePkt() -> TCPPkt? {
        if pkts.isEmpty {
            return nil
        }
        for pkt in pkts {
            if pkt.space > 0 {
                return pkt
            }
        }
        return nil
    }

    func getReadPkts() -> [TCPPkt] {
        var rpkts:[TCPPkt] = []
        for pkt in pkts {
            if pkt.size > 0 {
                rpkts.append(pkt)
            }
        }
        return rpkts
    }

    public var description: String {
        var str = String()
        for pkt in pkts {
            if pkt.size == 0 {
                break
            }
            str += "\(pkt)"
            str += "\n"
        }
        return str
    }
}
