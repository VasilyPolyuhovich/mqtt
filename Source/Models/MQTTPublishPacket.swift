import Foundation

class MQTTPublishPacket: MQTTPacket {
    
    let messageID: UInt16
    let message: MQTTPubMsg
    
    init(messageID: UInt16, message: MQTTPubMsg) {
        self.messageID = messageID
        self.message = message
        super.init(header: MQTTPacketFixedHeader(packetType: .publish, flags: MQTTPublishPacket.fixedHeaderFlags(for: message)))
    }
    
    class func fixedHeaderFlags(for message: MQTTPubMsg) -> UInt8 {
        var flags = UInt8(0)
        if message.retain {
            flags |= 0x01
        }
        flags |= message.QoS.rawValue << 1
        return flags
    }
    
    override func networkPacket() -> Data {
        // Variable Header
        var variableHeader = Data()
        variableHeader.mqtt_append(message.topic)
        if message.QoS != .atMostOnce {
            variableHeader.mqtt_append(messageID)
        }
        // Payload
        let payload = message.payload
        return finalPacket(variableHeader, payload: payload)
    }
    
    init(header: MQTTPacketFixedHeader, networkData: Data) {
        let bytes = networkData.mqtt_bytes
        let subBytes = bytes[3...bytes.endIndex]
        let payloadData = Data(bytes: subBytes)
        let payloadString = String(data: payloadData, encoding: .utf8)!
        let endOftopic = payloadString.index(of: "{") ?? payloadString.endIndex
        
        let topic = String(payloadString[payloadString.startIndex..<endOftopic])
        
        let payloadBody = String(payloadString[endOftopic..<payloadString.endIndex])
        
        let qos = MQTTQoS(rawValue: header.flags & 0x06)!
        let stringData = [UInt8](payloadBody.utf8)
        var payload = Data.init(bytes: stringData)
        
        if qos != .atMostOnce {
            messageID = 256 * UInt16(payload[0]) + UInt16(payload[1])
            payload = payload.subdata(in: 2..<payload.endIndex)
        } else {
            messageID = 0
        }
        
        let retain = (header.flags & 0x01) == 0x01
        message = MQTTPubMsg(topic: topic, payload: payload, retain: retain, QoS: qos)
        
        super.init(header: header)
    }
}
