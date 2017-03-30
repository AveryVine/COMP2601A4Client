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
        let source = (event.fields["SOURCE"] as! String)
        let destination = event.fields["DESTINATION"] as! String
        MasterViewController.instance?.playGameRequestHandler(source: source, destination: destination, stream: event.stream)
    }
}

class PlayGameResponseHandler: EventHandler {
    func handleEvent(event: Event) {
        print("PlayGameResponseHandler")
        let response = event.fields["ANSWER"] as! Bool
        let source = event.fields["SOURCE"] as! String
        DetailViewController.instance?.playGameResponseHandler(source: source, response: response, stream: event.stream)
    }
}

class GameOnHandler: EventHandler {
    func handleEvent(event: Event) {
        print("GameOnHandler")
        let opponentName = event.fields["SOURCE"] as! String
        DetailViewController.instance?.gameOnHandler(source: opponentName)
    }
}

class MoveMessageHandler: EventHandler {
    func handleEvent(event: Event) {
        print("MoveMessageHandler")
        let choice = event.fields["MOVE"] as! Int
        let source = event.fields["SOURCE"] as! String
        let destination = event.fields["DESTINATION"] as! String
        DetailViewController.instance?.moveMessageHandler(choice: choice, source: source, destination: destination)
    }
}

class GameOverHandler: EventHandler {
    func handleEvent(event: Event) {
        print("GameOverHandler")
        let destination = event.fields["DESTINATION"] as! String
        DetailViewController.instance?.gameOverHandler(reason: event.fields["REASON"] as! String, destination: destination, stream: event.stream)
    }
}
