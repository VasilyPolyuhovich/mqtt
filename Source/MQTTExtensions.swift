import Foundation

enum MQTTSessionError: Error {
    case none
    case socketError
}

enum MQTTPacketType: UInt8 {
    case connect        = 0x01
    case connAck        = 0x02
    case publish        = 0x03
    case pubAck         = 0x04
    case pubRec         = 0x05
    case pubRel         = 0x06
    case pubComp        = 0x07
    case subscribe      = 0x08
    case subAck         = 0x09
    case unSubscribe    = 0x0A
    case unSubAck       = 0x0B
    case pingReq        = 0x0C
    case pingResp       = 0x0D
    case disconnect     = 0x0E
}

public enum MQTTQoS: UInt8 {
    case atMostOnce     = 0x0
    case atLeastOnce    = 0x01
    case exactlyOnce    = 0x02
}

enum MQTTConnAckResponse: UInt8, Error {
    case connectionAccepted     = 0x00
    case badProtocol            = 0x01
    case clientIDRejected       = 0x02
    case serverUnavailable      = 0x03
    case badUsernameOrPassword  = 0x04
    case notAuthorized          = 0x05
}

extension UInt16 {
    // Most Significant Byte (MSB)
    private var highByte: UInt8 {
        return UInt8( (self & 0xFF00) >> 8)
    }
    // Least Significant Byte (LSB)
    private var lowByte: UInt8 {
        return UInt8(self & 0x00FF)
    }
    
    var hlBytes: [UInt8] {
        return [highByte, lowByte]
    }
}

extension UInt8 {
    func bitAt(_ offset: UInt8) -> UInt8 {
        return (self >> offset) & 0x01
    }
}

extension Data {
    public var mqtt_bytes: Array<UInt8> {
            return Array(self)
    }
        
    mutating func mqtt_encodeRemaining(length: Int) {
        var lengthOfRemainingData = length
        repeat {
            var digit = UInt8(lengthOfRemainingData % 128)
            lengthOfRemainingData /= 128
            if lengthOfRemainingData > 0 {
                digit |= 0x80
            }
            append(&digit, count: 1)
        } while lengthOfRemainingData > 0
    }
    
    mutating func mqtt_append(_ data: UInt8) {
        var varData = data
        append(&varData, count: 1)
    }
    
    // Appends two bytes
    // Big Endian
    mutating func mqtt_append(_ data: UInt16) {
        let byteOne = UInt8(data / 256)
        let byteTwo = UInt8(data % 256)
        mqtt_append(byteOne)
        mqtt_append(byteTwo)
    }
    
    mutating func mqtt_append(_ data: Data) {
        mqtt_append(UInt16(data.count))
        append(data)
    }
    
    mutating func mqtt_append(_ string: String) {
        mqtt_append(UInt16(string.count))
        append(string.data(using: .utf8)!)
    }
}
