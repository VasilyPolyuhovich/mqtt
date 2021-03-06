import Foundation

class MQTTPacket {
    
    let header: MQTTPacketFixedHeader
    
    init(header: MQTTPacketFixedHeader) {
        self.header = header
    }
    
    func networkPacket() -> Data {
        // To be implemented in subclasses
        return Data()
    }
    
    // Creates the actual packet to be sent using fixed header, variable header and payload
    // Automatically encodes remaining length
    func finalPacket(_ variableHeader: Data, payload: Data) -> Data {
        var remainingData = variableHeader
        remainingData.append(payload)
        
        var finalPacket = Data()
        finalPacket.append(header.networkPacket())
        finalPacket.mqtt_encodeRemaining(length: remainingData.count) // Remaining Length
        finalPacket.append(remainingData) // Remaining Data = Variable Header + Payload
        
        return finalPacket
    }
}
