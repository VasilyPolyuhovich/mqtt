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
        let qos = MQTTQoS(rawValue: header.flags & 0x06)!
        
        let bytes = networkData.mqtt_bytes
        let topicLength = Int(bytes[0]) + Int(bytes[1])
        let topicBytes = bytes[2..<topicLength + 2]
        let topicData = Data(bytes: topicBytes)
        let startPosition = topicLength + 4
        let subBytes = bytes[startPosition..<bytes.endIndex]
        let payloadData = Data(bytes: subBytes)
        
        let topic = String(data: topicData, encoding: .utf8) ?? ""
        
        var payload = payloadData
        
        if qos != .atMostOnce {
            let msgId = bytes[startPosition-2..<startPosition]
            let msgData = Data.init(bytes: msgId)
            messageID =  UInt16(msgData[0]) << 8 | UInt16(msgData[1])
            payload = payloadData
        } else {
            messageID = 0
        }
        
        let retain = (header.flags & 0x01) == 0x01
        message = MQTTPubMsg(topic: topic, payload: payload, retain: retain, QoS: qos)
        
        super.init(header: header)
    }
}
