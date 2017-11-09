import Foundation

class MQTTConnAckPacket: MQTTPacket {
    
    let sessionPresent: Bool
    let response: MQTTConnAckResponse
    
    init(header: MQTTPacketFixedHeader, networkData: Data) {
        sessionPresent = (networkData[0] & 0x01) == 0x01
        response = MQTTConnAckResponse(rawValue: networkData[1])!
        
        super.init(header: header)
    }
}
