import Foundation
import Starscream

protocol MQTTSessionStreamDelegate {
    func mqttErrorOccurred(in stream: MQTTSessionStream)
    func mqttReceived(_ data: Data, header: MQTTPacketFixedHeader, in stream: MQTTSessionStream)
}

class MQTTSessionStream: NSObject {
    var reconnect: Bool = true
    
    internal let host: String
    internal let port: UInt16
    internal let ssl: Bool
    
    internal var delegate: MQTTSessionStreamDelegate?
    internal var socket: WebSocket?
    
    init(host: String, port: UInt16, ssl: Bool) {
        self.host = host
        self.port = port
        self.ssl = ssl
    }
    
    func createStreamConnection(_ completion: @escaping () -> Void) {
        guard let url = URL.init(string: "\(host):\(port)") else {
            assertionFailure("wrong chat url")
            return
        }
        
        socket = WebSocket(url: url)
        
        if ssl {
             socket?.disableSSLCertValidation = true
        } else {
            let certUrl = Bundle.main.url(forResource: "cert", withExtension: "pem")
            
            if let file = certUrl, let data = try? Data.init(contentsOf: file) {
                socket?.disableSSLCertValidation = false
                socket?.security = SSLSecurity(certs: [SSLCert(data: data)], usePublicKeys: true)
            } else {
                socket?.disableSSLCertValidation = true
            }
        }
        
        socket?.onData = { data in
            self.receiveData(data)
        }
        
        socket?.onDisconnect = { error in
            if self.reconnect {
                self.socket?.connect()
            }
        }
        
        socket?.onConnect = {
            completion()
        }

        socket?.connect()
    }
    
    func closeStreams() {
        reconnect = false
        socket?.disconnect()
    }
    
    func send(_ packet: MQTTPacket) -> Int {
        let networkPacket = packet.networkPacket()
        
        socket?.write(data: networkPacket, completion: {
            print("sent \(packet.header.packetType)")
        })
        
        return networkPacket.count
    }
    
    fileprivate func receiveData(_ data: Data) {
        guard data.count > 0 else { return }
        
        let header = MQTTPacketFixedHeader(networkByte: data[0])
        
        // Max Length is 2^28 = 268,435,455 (256 MB)
        
        let totalLength = data[1]
        
        var responseData = Data()
        if totalLength > 0 {
            responseData = Data.init(bytes: data.bytes[2...data.bytes.count])
        }
        delegate?.mqttReceived(responseData, header: header, in: self)
    }
}
