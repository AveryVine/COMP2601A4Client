//
//  MasterViewController.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine on 2017-03-26.
//  Copyright © 2017 Avery Vine. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    static var instance: MasterViewController?
    var randomGenID = ""
    var deviceName: String!
    var opponentName: String!
    var acceptor: AcceptorReactor?

    var detailViewController: DetailViewController? = nil
    var services = [NetService]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //navigationItem.leftBarButtonItem = editButtonItem

        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        MasterViewController.instance = self
        
        for _ in 0 ..< 8 {
            randomGenID += String(arc4random_uniform(10))
        }
        deviceName = UIDevice.current.name + " (" + randomGenID + ")"
        
        acceptor = AcceptorReactor(domain: "local.", type: "_tictactoe._tcp.", name: deviceName + "0", port: 8889)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateServices(services: [NetService]) {
        self.services = services
        tableView.reloadData()
    }

    // MARK: - Segues
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let service = services[indexPath.row]
                if service.name.substring(from: service.name.index(service.name.endIndex, offsetBy: -1)) == "0" {
                    return true
                }
            }
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let service = services[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = service
                opponentName = service.name.substring(to: service.name.index(service.name.endIndex, offsetBy: -1))
                controller.openConnection(acceptor: acceptor!, hostName: service.hostName!, port: UInt16(service.port))
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        else {
            let serviceIndex = services.index(of: sender as! NetService)
            let indexPath = IndexPath(row: serviceIndex!, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            let service = services[indexPath.row]
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem = service
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
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
        cell.textLabel!.text = service.name.substring(to: service.name.index(service.name.endIndex, offsetBy: -1))
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

    func playGameRequest(opponentName: String, stream: EventStream) {
        self.opponentName = opponentName
        let refreshAlert = UIAlertController(title: "Tic Tac Toe", message: "\(opponentName) has challenged you to a game.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (action: UIAlertAction!) in
            print("Sending Accept")
            Event(stream: stream,
                  fields: ["TYPE": "PLAY_GAME_RESPONSE",
                           "SOURCE": self.deviceName,
                           "DESTINATION": self.opponentName,
                           "ANSWER": true]).put()
            self.performSegue(withIdentifier: "showDetail", sender: self)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Sending Decline")
            Event(stream: stream,
                  fields: ["TYPE": "PLAY_GAME_RESPONSE",
                           "SOURCE": self.deviceName,
                           "DESTINATION": self.opponentName,
                           "ANSWER": false]).put()
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func playGameRequestDeclined(opponentName: String) {
        let refreshAlert = UIAlertController(title: "Tic Tac Toe", message: "\(opponentName) is unavailable to play.", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(refreshAlert, animated: true, completion: nil)
    }
}

