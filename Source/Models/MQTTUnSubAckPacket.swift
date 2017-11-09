import Foundation

class MQTTUnSubAckPacket: MQTTPacket {
    
    let messageID: UInt16
    
    init(header: MQTTPacketFixedHeader, networkData: Data) {
        messageID = (UInt16(networkData[0]) * UInt16(256)) + UInt16(networkData[1])
        super.init(header: header)
    }
}
