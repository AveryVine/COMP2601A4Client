//
//  ReactorImpl.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine on 2017-03-26.
//  Copyright © 2017 Avery Vine. All rights reserved.
//

import Foundation

class ReactorImpl: Reactor {
    
    var handlers: [String:EventHandler] = [:]
    
    func register(name: String, handler: EventHandler) {
        handlers[name] = handler
    }
    
    func deregister(name: String) {
        handlers.removeValue(forKey: name)
    }
    
    func dispatch(event: Event) {
        let type = event.fields["TYPE"] as! String
        let handler = handlers[type]
        if handler != nil {
            handler?.handleEvent(event: event)
        }
    }
}
