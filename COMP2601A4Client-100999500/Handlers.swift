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
        let opponentName = event.fields["SOURCE"] as! String
        MasterViewController.instance?.playGameRequestHandler(opponentName: opponentName, stream: event.stream)
    }
}

class PlayGameResponseHandler: EventHandler {
    func handleEvent(event: Event) {
        print("PlayGameResponseHandler")
        let response = event.fields["ANSWER"] as! Bool
        DetailViewController.instance?.playGameResponseHandler(response: response, opponentName: event.fields["SOURCE"] as! String, stream: event.stream)
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
        DetailViewController.instance?.gameOverHandler(reason: event.fields["REASON"] as! String)
    }
}
