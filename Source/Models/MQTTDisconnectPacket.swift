import Foundation

class MQTTDisconnectPacket: MQTTPacket {
    
    init() {
        super.init(header: MQTTPacketFixedHeader(packetType: .disconnect, flags: 0))
    }
    
    override func networkPacket() -> Data {
        return finalPacket(Data(), payload: Data())
    }
}
