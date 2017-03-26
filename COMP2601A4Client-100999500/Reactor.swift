//
//  Reactor.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine on 2017-03-26.
//  Copyright © 2017 Avery Vine. All rights reserved.
//

import Foundation

protocol Reactor {
    func register(name: String, handler: EventHandler)
    func deregister(name: String)
    func dispatch(event: Event)
}
