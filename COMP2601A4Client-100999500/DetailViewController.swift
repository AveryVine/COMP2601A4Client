//
//  DetailViewController.swift
//  COMP2601A4Client-100999500
//
//  Created by Avery Vine (100999500) and Alexei Tipenko (100995947) on 2017-03-26.
//  Copyright © 2017 Avery Vine and Alexei Tipenko. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, Observer {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet var tile0: UIButton?
    @IBOutlet var tile1: UIButton?
    @IBOutlet var tile2: UIButton?
    @IBOutlet var tile3: UIButton?
    @IBOutlet var tile4: UIButton?
    @IBOutlet var tile5: UIButton?
    @IBOutlet var tile6: UIButton?
    @IBOutlet var tile7: UIButton?
    @IBOutlet var tile8: UIButton?
    @IBOutlet var label: UILabel?
    @IBOutlet var button: UIButton?
    
    static var instance: DetailViewController?
    var stream: EventStream?
    var acceptor: AcceptorReactor?
    var game = Game()
    var playerTurn: Int!
    var xImage = UIImage(named: "x_button")
    var oImage = UIImage(named: "o_button")
    var emptyImage = UIImage(named: "empty_button")
    let strings = Strings()



    func configureView() {
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Override the provided back button in order to provide a function that can disconnect sockets
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = false
        navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Close Game", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController.back(sender:)))
        navigationItem.setLeftBarButton(newBackButton, animated: true)
        
        DetailViewController.instance = self
        configureView()
        
        acceptor = MasterViewController.instance?.acceptor
        
        // Check whether the current player is the one initiating or receiving a connection
        if detailItem != nil {
            playerTurn = Game.X_VAL
            openConnection(host: (detailItem?.hostName)!, port: UInt16((detailItem?.port)!))
        }
        else {
            playerTurn = Game.O_VAL
            stream = MasterViewController.instance?.stream
        }
        
        initUI()
        game.toggleActive()
        toggleClickListeners()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

    var detailItem: NetService? {
        didSet {
            configureView()
        }
    }
    
    
    
    // Set the AcceptorReactor to the one provided by the Master View Controller
    func setAcceptor(acceptor: AcceptorReactor) {
        self.acceptor = acceptor
    }
    
    
    
    // Open a connection
    func openConnection(host: String, port: UInt16) {
        MasterViewController.instance?.inGame = MasterViewController.instance?.BETWEEN_GAMES
        acceptor?.open(host: host, port: port)
        DispatchQueue.main.async {
            self.label?.text = self.strings.waitingForOpponent
            self.button?.isEnabled = false
        }
    }
    
    
    /*----------
     - Description: observer function that updates the UI when a move is made
     - Input: the choice of move
     - Return: none
     ----------*/
    func updateMove(choice: Int) {
        updateSquareUI(choice: choice, playerTurn: game.getPlayerTurn())
        updateDisplayTextView(choice: choice)
    }
    
    
    
    /*----------
     - Description: observer function that updates the UI when the game ends
     - Input: the winner of the game
     - Return: none
     ----------*/
    func updateGameWinner(winner: Int, gameEnder: String) {
        DispatchQueue.main.async {
            self.gameOverUI(winner: winner, gameEnder: gameEnder)
        }
    }
    
    
    
    /*----------
     - Description: runs when the Start/Running button is clicked
     - Input: none
     - Return: none
     ----------*/
    @IBAction func startButtonOnClick() {
        if game.getActive() {
            game.toggleActive()
            gameOverUI(winner: Game.EMPTY_VAL, gameEnder: (MasterViewController.instance?.deviceName)!)
            if playerTurn == game.getPlayerTurn() { toggleClickListeners() }
            let source = (MasterViewController.instance?.deviceName)!
            let destination = (MasterViewController.instance?.opponentName)!
            Event(stream: stream!, fields: ["TYPE": "GAME_OVER", "SOURCE": source, "DESTINATION": destination, "REASON": strings.no_winner]).put()
        }
        else if playerTurn == Game.X_VAL {
            game = Game()
            self.game.attachObserver(observer: self)
            prepareUI()
            toggleClickListeners()
            let source = (MasterViewController.instance?.deviceName)!
            let destination = (MasterViewController.instance?.opponentName)!
            Event(stream: stream!, fields: ["TYPE": "GAME_ON", "SOURCE": source, "DESTINATION": destination]).put()
        }
    }
    
    
    
    /*----------
     - Description: updates the UI based off the player's move
     - Input: the position on the board, the current player
     - Return: none
     ----------*/
    func updateSquareUI(choice: Int, playerTurn: Int) {
        var image: UIImage?
        if playerTurn == Game.X_VAL {
            image = xImage
        }
        else {
            image = oImage
        }
        DispatchQueue.main.async {
            switch choice {
            case 0:
                self.tile0?.setImage(image, for: UIControlState.normal)
                break
            case 1:
                self.tile1?.setImage(image, for: UIControlState.normal)
                break
            case 2:
                self.tile2?.setImage(image, for: UIControlState.normal)
                break
            case 3:
                self.tile3?.setImage(image, for: UIControlState.normal)
                break
            case 4:
                self.tile4?.setImage(image, for: UIControlState.normal)
                break
            case 5:
                self.tile5?.setImage(image, for: UIControlState.normal)
                break
            case 6:
                self.tile6?.setImage(image, for: UIControlState.normal)
                break
            case 7:
                self.tile7?.setImage(image, for: UIControlState.normal)
                break
            case 8:
                self.tile8?.setImage(image, for: UIControlState.normal)
                break
            default:
                print("Error setting button image")
            }
        }
    }
    
    
    
    /*----------
     - Description: updates the text view with the last move played
     - Input: the position of the move
     - Return: none
     ----------*/
    func updateDisplayTextView(choice: Int) {
        print("\(game.getPlayerTurn()), \(playerTurn)")
        if game.getPlayerTurn() == playerTurn {
            DispatchQueue.main.async {
                if choice == 0 { self.label?.text = self.strings.square0 + self.strings.you }
                else if choice == 1 { self.label?.text = self.strings.square1 + self.strings.you }
                else if choice == 2 { self.label?.text = self.strings.square2 + self.strings.you }
                else if choice == 3 { self.label?.text = self.strings.square3 + self.strings.you }
                else if choice == 4 { self.label?.text = self.strings.square4 + self.strings.you }
                else if choice == 5 { self.label?.text = self.strings.square5 + self.strings.you }
                else if choice == 6 { self.label?.text = self.strings.square6 + self.strings.you }
                else if choice == 7 { self.label?.text = self.strings.square7 + self.strings.you }
                else if choice == 8 { self.label?.text = self.strings.square8 + self.strings.you }
                else { self.label?.text = self.strings.blank }
            }
        }
        else {
            DispatchQueue.main.async {
                let opponentName = (MasterViewController.instance?.opponentName)!
                if choice == 0 { self.label?.text = self.strings.square0 + opponentName}
                else if choice == 1 { self.label?.text = self.strings.square1 + opponentName }
                else if choice == 2 { self.label?.text = self.strings.square2 + opponentName}
                else if choice == 3 { self.label?.text = self.strings.square3 + opponentName}
                else if choice == 4 { self.label?.text = self.strings.square4 + opponentName}
                else if choice == 5 { self.label?.text = self.strings.square5 + opponentName}
                else if choice == 6 { self.label?.text = self.strings.square6 + opponentName}
                else if choice == 7 { self.label?.text = self.strings.square7 + opponentName}
                else if choice == 8 { self.label?.text = self.strings.square8 + opponentName}
                else { self.label?.text = self.strings.blank }
            }
        }
    }
    
    
    
    /*----------
     - Description: sets the initial state for the UI when the program begins
     - Input: none
     - Return: none
     ----------*/
    func initUI() {
        if playerTurn == Game.X_VAL {
            button?.setTitle(strings.startButton_gameInactive, for: UIControlState.normal)
            label?.text = strings.displayTextView_gameInactive
        }
        else {
            label?.text = strings.waitingForOpponent
            button?.setTitle(strings.startButton_gameWaiting, for: UIControlState.normal)
            button?.isEnabled = false
        }
        wipeSquares()
    }
    
    
    
    /*----------
     - Description: prepares the UI for a new game
     - Input: none
     - Return: none
     ----------*/
    func prepareUI() {
        wipeSquares()
        button?.setTitle(strings.startButton_gameActive, for: UIControlState.normal)
        label?.text = strings.blank
    }
    
    
    
    /*----------
     - Description: sets every square on the board to empty
     - Input: none
     - Return: none
     ----------*/
    func wipeSquares() {
        DispatchQueue.main.async {
            self.tile0?.setImage(self.emptyImage, for: UIControlState.normal)
            self.tile1?.setImage(self.emptyImage, for: UIControlState.normal)
            self.tile2?.setImage(self.emptyImage, for: UIControlState.normal)
            self.tile3?.setImage(self.emptyImage, for: UIControlState.normal)
            self.tile4?.setImage(self.emptyImage, for: UIControlState.normal)
            self.tile5?.setImage(self.emptyImage, for: UIControlState.normal)
            self.tile6?.setImage(self.emptyImage, for: UIControlState.normal)
            self.tile7?.setImage(self.emptyImage, for: UIControlState.normal)
            self.tile8?.setImage(self.emptyImage, for: UIControlState.normal)
        }
    }
    
    
    
    /*----------
     - Description: displays the "Game Over" UI to the user
     - Input: the winner of the game, the player who ended the game (sometimes different)
     - Return: none
     ----------*/
    func gameOverUI(winner: Int, gameEnder: String) {
        DispatchQueue.main.async {
            if winner == Game.TIE_VAL {
                self.label?.text = self.strings.tie_winner
            }
            else if winner == Game.EMPTY_VAL {
                if gameEnder == (MasterViewController.instance?.deviceName)! {
                    self.label?.text = self.strings.you + self.strings.no_winner
                }
                else {
                    self.label?.text = (MasterViewController.instance?.opponentName)! + self.strings.no_winner
                }
            }
            else if winner == self.playerTurn {
                self.label?.text = self.strings.you + self.strings.gameOver
            }
            else {
                self.label?.text = (MasterViewController.instance?.opponentName)! + self.strings.gameOver
            }
            if self.playerTurn == Game.X_VAL {
                self.button?.setTitle(self.strings.startButton_gameInactive, for: UIControlState.normal)
            }
            else {
                self.button?.isEnabled = false
                self.button?.setTitle(self.strings.startButton_gameWaiting, for: UIControlState.normal)
            }
        }
    }
    
    
    
    /*----------
     - Description: toggles on and off the squares' click listeners
     - Input: none
     - Return: none
     ----------*/
    func toggleClickListeners() {
        tile0?.isEnabled = !(tile0?.isEnabled)!
        tile1?.isEnabled = !(tile1?.isEnabled)!
        tile2?.isEnabled = !(tile2?.isEnabled)!
        tile3?.isEnabled = !(tile3?.isEnabled)!
        tile4?.isEnabled = !(tile4?.isEnabled)!
        tile5?.isEnabled = !(tile5?.isEnabled)!
        tile6?.isEnabled = !(tile6?.isEnabled)!
        tile7?.isEnabled = !(tile7?.isEnabled)!
        tile8?.isEnabled = !(tile8?.isEnabled)!
    }
    
    
    
    /*----------
     - Description: runs when a square on the board is clicked
     - Input: the button that was pressed
     - Return: none
     ----------*/
    @IBAction func squareClicked(sender: UIButton) {
        let choice = sender.tag
        if !game.squareOccupied(square: choice) {
            game.makeMove(choice: choice)
            let source = (MasterViewController.instance?.deviceName)!
            let destination = (MasterViewController.instance?.opponentName)!
            Event(stream: stream!, fields: ["TYPE": "MOVE_MESSAGE", "SOURCE": source, "DESTINATION": destination, "MOVE": choice]).put()
            toggleClickListeners()
            game.switchPlayer()
        }
    }
    
    
    
    /*
     - Description: pops the detail view controller and disconnects the stream, if applicable
     - Input: the back button
     - Return: none
     */
    func back(sender: UIBarButtonItem) {
        print("Back button pressed")
        if stream != nil {
            acceptor?.disconnect(stream: stream!)
            stream = nil
        }
        _ = navigationController?.navigationController?.popViewController(animated: true)
    }
    
    
    
    /*
     - Description: runs when the opponent disconnects from a game
     - Input: none
     - Return: none
     */
    func opponentDisconnected() {
        let opponentName = (MasterViewController.instance?.opponentName)!
        let alert = UIAlertController(title: "Tic Tac Toe", message: "\(opponentName) has disconnected.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
        self.button?.isEnabled = false
        MasterViewController.instance?.inGame = MasterViewController.instance?.BETWEEN_GAMES
    }
    
    

    /*
     - Description: depending on opponent's response: pops the view controller and disconnects, or allows the game to be started
     - Input: the source player's name, the response from the player, the event's stream connection
     - Return: none
     */
    func playGameResponseHandler(source: String, response: Bool, stream: EventStream) {
        print("Response: \(response)")
        if response {
            self.stream = stream
            MasterViewController.instance?.inGame = MasterViewController.instance?.IN_GAME
            DispatchQueue.main.async {
                self.label?.text = self.strings.displayTextView_gameInactive
                self.button?.isEnabled = true
            }
        }
        else {
            stream.close()
            _ = navigationController?.navigationController?.popViewController(animated: true)
            MasterViewController.instance?.playGameRequestDeclined(opponentName: source)
        }
    }
    
    
    
    /*
     - Description: starts up a new game
     - Input: the source player's name
     - Return: none
     */
    func gameOnHandler(source: String) {
        prepareUI()
        DispatchQueue.main.async {
            self.label?.text = source + self.strings.displayTextView_gameStart
            self.button?.isEnabled = true
        }
        game = Game()
        self.game.attachObserver(observer: self)
    }
    
    
    
    /*
     - Description: receives a move from the opponent
     - Input: the move made, the source player's name, the destination player's name
     - Return: none
     */
    func moveMessageHandler(choice: Int, source: String, destination: String) {
        game.makeMove(choice: choice)
        
        let gameWinner = game.gameWinner(notify: true)
        if gameWinner == Game.EMPTY_VAL {
            game.switchPlayer()
            DispatchQueue.main.async {
                self.toggleClickListeners()
            }
        }
        else {
            self.game.toggleActive()
            Event(stream: stream!, fields: ["TYPE": "GAME_OVER", "SOURCE": destination, "DESTINATION": source, "REASON": source + " won the game."]).put()
        }
    }
    
    
    
    /*
     - Description: displays the gameOverUI, as the game has ended for some reason
     - Input: the reason for the game ending, the event's stream connection
     - Return: none
     */
    func gameOverHandler(reason: String, stream: EventStream) {
        game.toggleActive()
        if reason == strings.no_winner {
            if playerTurn == game.getPlayerTurn() { toggleClickListeners() }
            gameOverUI(winner: Game.EMPTY_VAL, gameEnder: reason)
        }
        else {
            if game.gameWinner(notify: false) == Game.TIE_VAL {
                gameOverUI(winner: Game.TIE_VAL, gameEnder: reason)
            }
            else {
                gameOverUI(winner: playerTurn, gameEnder: reason)
            }
        }
    }
}

