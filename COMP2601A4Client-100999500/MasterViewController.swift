//
//  MasterViewController.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine (100999500) and Alexei Tipenko (100995947) on 2017-03-26.
//  Copyright © 2017 Avery Vine and Alexei Tipenko. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    let IN_GAME = 2
    let BETWEEN_GAMES = 1
    let NOT_IN_GAME = 0
    
    static var instance: MasterViewController?
    var inGame: Int!
    var deviceName: String!
    var opponentName: String!
    var acceptor: AcceptorReactor?
    var stream: EventStream?

    var detailViewController: DetailViewController? = nil
    var services = [NetService]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        MasterViewController.instance = self
        
        deviceName = UIDevice.current.name
        
        // AcceptorReactor contains the code for advertising a service, browsing for services, and connecting to a service
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
    
    
    
    // Sets the inGame status of the player
    override func viewDidAppear(_ animated: Bool) {
        inGame = NOT_IN_GAME
        opponentName = nil
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // Updates the list of services on the master view controller list
    func updateServices(services: [NetService]) {
        self.services = services
        tableView.reloadData()
    }

    

    // Runs when a segue is about to occur after a player is tapped on the master view controller list
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let service = services[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = service
                opponentName = service.name // Set the opponent name, to reference later
            }
        }
    }

    

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
        return false
    }
    
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            services.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }

    
    
    /*
     - Description: pops up an alert asking if the player wishes to enter a game
     - Input: the source player's name, the destination player's name, the stream used for communication
     - Return: none
     */
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
    
    
    
    /*
     - Description: after the player accepts an incoming game, sends a response to the opponent and segues
     - Input: the source player's name, the destination player's name, the stream used for communication
     - Return: none
     */
    func acceptGame(source: String, destination: String, stream: EventStream) {
        Event(stream: stream,
              fields: ["TYPE": "PLAY_GAME_RESPONSE",
                       "SOURCE": source,
                       "DESTINATION": destination,
                       "ANSWER": true]).put()
        inGame = IN_GAME
        self.stream = stream
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    
    
    /*
     - Description: after the player declines an incoming game, sends a response to the opponent
     - Input: the source player's name, the destination player's name, the stream used for communication
     - Return: none
     */
    func declineGame(source: String, destination: String, stream: EventStream) {
        Event(stream: stream,
              fields: ["TYPE": "PLAY_GAME_RESPONSE",
                       "SOURCE": source,
                       "DESTINATION": destination,
                       "ANSWER": false]).put()
    }
    
    
    
    /*
     - Description: alerts the player when a prospective opponent is unavailable to play
     - Input: the name of the opponent who is unavailable
     - Return: none
     */
    func playGameRequestDeclined(opponentName: String) {
        let alert = UIAlertController(title: "Tic Tac Toe", message: "\(opponentName) is unavailable to play.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

