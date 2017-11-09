import Foundation

class MQTTPingResp: MQTTPacket {
    
    override init(header: MQTTPacketFixedHeader) {
        super.init(header: header)
    }
}
