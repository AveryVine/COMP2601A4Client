//
//  JSONEventStream.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine on 2017-03-26.
//  Copyright © 2017 Avery Vine. All rights reserved.
//

import Foundation

class JSONEventStream: EventStream {
    
    var socket: Socket?
    let nl = "\n".data(using: .ascii)
    
    init(socket: Socket) {
        self.socket = socket
    }
    
    func get(data: Data) -> Event {
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
        
        let event = Event(stream: self, fields: json!)
        return event
    }
    
    func get() {
        socket?.readData(to: nl!, withTimeout: -1, tag: 0)
    }
    
    func put(event: Event) {
        let output = try? JSONSerialization.data(withJSONObject: event.fields, options: [])
        socket?.write(output!, withTimeout: -1, tag: 0)
        socket?.write(nl!, withTimeout: -1, tag: 0)
    }
    
    func close() {
        socket?.disconnect()
    }
}
