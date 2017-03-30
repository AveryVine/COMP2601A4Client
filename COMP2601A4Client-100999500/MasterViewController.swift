//
//  MasterViewController.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine on 2017-03-26.
//  Copyright © 2017 Avery Vine. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    let IN_GAME = 2
    let BETWEEN_GAMES = 1
    let NOT_IN_GAME = 0
    
    static var instance: MasterViewController?
    var randomGenID = ""
    var inGame: Int!
    var deviceName: String!
    var opponentName: String!
    var acceptor: AcceptorReactor?
    var stream: EventStream?

    var detailViewController: DetailViewController? = nil
    var services = [NetService]()
    
//    ----------------------------------------
//    IF YOU HAVE TIME, FIX THIS BUG
//    Player1: Tap Player2's name
//    Player2: Accept the request from Player1
//    Player2: Tap Close Game button
//    Player1: No disconnect alert pops up here
//    ----------------------------------------


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        MasterViewController.instance = self
        
        for _ in 0 ..< 8 {
            randomGenID += String(arc4random_uniform(10))
        }
        deviceName = UIDevice.current.name + " (" + randomGenID + ")"
        
        acceptor = AcceptorReactor(domain: "local.", type: "_tictactoe._tcp.", name: deviceName, port: 8889)
        acceptor?.register(name: "PLAY_GAME_REQUEST", handler: PlayGameRequestHandler())
        acceptor?.register(name: "PLAY_GAME_RESPONSE", handler: PlayGameResponseHandler())
        acceptor?.register(name: "GAME_ON", handler: GameOnHandler())
        acceptor?.register(name: "MOVE_MESSAGE", handler: MoveMessageHandler())
        acceptor?.register(name: "GAME_OVER", handler: GameOverHandler())
        
        DispatchQueue(label: "serviceQueue", qos: .background, attributes: .concurrent).async {
            self.acceptor?.accept(on: 8889)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        inGame = NOT_IN_GAME
        print("Updated inGame Status to \(inGame)")
        opponentName = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateServices(services: [NetService]) {
        self.services = services
        tableView.reloadData()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let service = services[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = service
                opponentName = service.name
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let service = services[indexPath.row]
        cell.textLabel!.text = service.name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            services.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    func playGameRequestHandler(source: String, destination: String, stream: EventStream) {
        self.opponentName = source
        if inGame != NOT_IN_GAME {
            declineGame(source: destination, destination: source, stream: stream)
        }
        else {
            let alert = UIAlertController(title: "Tic Tac Toe", message: "\(opponentName!) has challenged you to a game.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (action: UIAlertAction!) in
                self.acceptGame(source: destination, destination: source, stream: stream)
            }))
            
            alert.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { (action: UIAlertAction!) in
                self.declineGame(source: destination, destination: source, stream: stream)
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func acceptGame(source: String, destination: String, stream: EventStream) {
        Event(stream: stream,
              fields: ["TYPE": "PLAY_GAME_RESPONSE",
                       "SOURCE": source,
                       "DESTINATION": destination,
                       "ANSWER": true]).put()
        print("Accepted game")
        inGame = IN_GAME
        print("Updated inGame Status to \(inGame)")
        self.stream = stream
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func declineGame(source: String, destination: String, stream: EventStream) {
        print("Sending Decline")
        Event(stream: stream,
              fields: ["TYPE": "PLAY_GAME_RESPONSE",
                       "SOURCE": source,
                       "DESTINATION": destination,
                       "ANSWER": false]).put()
    }
    
    func playGameRequestDeclined(opponentName: String) {
        let alert = UIAlertController(title: "Tic Tac Toe", message: "\(opponentName) is unavailable to play.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

