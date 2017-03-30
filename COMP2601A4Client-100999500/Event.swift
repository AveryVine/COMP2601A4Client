//
//  Event.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine (100999500) and Alexei Tipenko (100995947) on 2017-03-26.
//  Copyright © 2017 Avery Vine and Alexei Tipenko. All rights reserved.
//

import Foundation

class Event : EventStream {
    var stream : EventStream
    var fields: [String: Any]
    
    init(stream: EventStream, fields: [String: Any]) {
        self.stream = stream
        self.fields = fields
    }
    
    func get() {
        stream.get()
    }
    
    func get(data: Data) -> Event {
        return stream.get(data: data)
    }
    
    func put(event: Event) {
        stream.put(event: event)
    }
    
    func put() {
        put(event: self)
    }
    
    func close() {
        stream.close()
    }
}
