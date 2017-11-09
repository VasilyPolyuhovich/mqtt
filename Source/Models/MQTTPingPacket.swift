import Foundation

class MQTTPingPacket: MQTTPacket {
    
    init() {
        super.init(header: MQTTPacketFixedHeader(packetType: MQTTPacketType.pingReq, flags: 0))
    }
    
    override func networkPacket() -> Data {
        return finalPacket(Data(), payload: Data())
    }
}
