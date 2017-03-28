//
//  Handlers.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine on 2017-03-26.
//  Copyright © 2017 Avery Vine. All rights reserved.
//

import Foundation

class PlayGameRequestHandler: EventHandler {
    func handleEvent(event: Event) {
        print("PlayGameRequestHandler")
        MasterViewController.instance?.playGameRequest(event: event)
    }
}

class PlayGameResponseHandler: EventHandler {
    func handleEvent(event: Event) {
        print("PlayGameResponseHandler")
    }
}

class GameOnHandler: EventHandler {
    func handleEvent(event: Event) {
        print("GameOnHandler")
    }
}

class MoveMessageHandler: EventHandler {
    func handleEvent(event: Event) {
        print("MoveMessageHandler")
    }
}

class GameOverHandler: EventHandler {
    func handleEvent(event: Event) {
        print("GameOverHandler")
    }
}
