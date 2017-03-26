//
//  EventStream.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine on 2017-03-26.
//  Copyright © 2017 Avery Vine. All rights reserved.
//

import Foundation

typealias Socket = GCDAsyncSocket
typealias SocketDelegate = GCDAsyncSocketDelegate

protocol EventStreamInput {
    func get()
    func get(data: Data) -> Event
}

protocol EventOutputStream {
    func put(event: Event)
}

protocol Closeable {
    func close()
}

protocol EventStream: EventStreamInput, EventOutputStream, Closeable {
}
