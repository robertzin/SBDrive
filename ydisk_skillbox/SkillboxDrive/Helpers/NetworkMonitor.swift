//
//  NetworkMonitor.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 10.01.2023.
//

import Foundation
import Network

//extension Notification.Name {
//    static let connectivityStatus = Notification.Name(rawValue: "connectivityStatusChanged")
//}

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue(label: "Monitor")
    private let monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = false
    private var hasStatus: Bool = false
    
    private init() {
        monitor = NWPathMonitor()
        isConnected = false
    }
    
    public func start() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            #if targetEnvironment(simulator)
                if (!self.hasStatus) {
                    self.isConnected = path.status == .satisfied
                    self.hasStatus = true
                } else {
                    self.isConnected = !self.isConnected
                }
            #else
                self?.isConnected = path.status == .satisfied
            #endif
//                print("isConnected: " + String(self.isConnected))
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:  "connectivityStatusChanged"), object: nil)
        }
    }
    
    public func stop() {
        monitor.cancel()
    }
}
