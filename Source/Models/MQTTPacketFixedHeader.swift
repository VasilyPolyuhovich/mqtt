import Foundation

class MQTTPacketFixedHeader {
    
    let packetType: MQTTPacketType
    let flags: UInt8
    
    init(packetType: MQTTPacketType, flags: UInt8) {
        self.packetType = packetType
        self.flags = flags
    }
    
    init(networkByte: UInt8) {
        packetType = MQTTPacketType(rawValue: networkByte >> 4)!
        flags = networkByte & 0x0F
    }
    
    func networkPacket() -> Data {
        var fixedHeaderFirstByte = UInt8(0)
        fixedHeaderFirstByte = (0x0F & flags) | (packetType.rawValue << 4)
        return Data(bytes: &fixedHeaderFirstByte, count: 1)
    }
}
