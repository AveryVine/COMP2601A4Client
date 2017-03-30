//
//  COMP2601A4Client_100999500Tests.swift
//  COMP2601A4Client-100999500Tests
//
//  Created by Avery Vine (100999500) and Alexei Tipenko (100995947) on 2017-03-26.
//  Copyright © 2017 Avery Vine and Alexei Tipenko. All rights reserved.
//

import XCTest
@testable import COMP2601A4Client_100999500

class COMP2601A4Client_100999500Tests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func makeMove() {
        let game = Game()
        let choice = 0
        let playerTurn = game.getPlayerTurn()
        
        game.makeMove(choice: choice)
        XCTAssert(playerTurn == game.getSquare(choice: choice), "Pass")
    }
    
    func gameWinner() {
        let game1 = Game()
        let game2 = Game()
        let game3 = Game()
        let game4 = Game()
        
        game1.makeMove(choice: 0)
        game1.switchPlayer()
        game1.makeMove(choice: 1)
        game1.switchPlayer()
        game1.makeMove(choice: 5)
        game1.switchPlayer()
        game1.makeMove(choice: 3)
        game1.switchPlayer()
        game1.makeMove(choice: 2)
        game1.switchPlayer()
        game1.makeMove(choice: 4)
        game1.switchPlayer()
        game1.makeMove(choice: 6)
        game1.switchPlayer()
        game1.makeMove(choice: 7)
        XCTAssert(Game.O_VAL == game1.gameWinner(notify: false), "Pass")
        
        game2.makeMove(choice: 0)
        game2.switchPlayer()
        game2.makeMove(choice: 1)
        game2.switchPlayer()
        game2.makeMove(choice: 5)
        game2.switchPlayer()
        game2.makeMove(choice: 3)
        game2.switchPlayer()
        game2.makeMove(choice: 2)
        game2.switchPlayer()
        game2.makeMove(choice: 8)
        game2.switchPlayer()
        game2.makeMove(choice: 4)
        game2.switchPlayer()
        game2.makeMove(choice: 7)
        game2.switchPlayer()
        game2.makeMove(choice: 6)
        XCTAssert(Game.X_VAL == game2.gameWinner(notify: false), "Pass")
        
        game3.makeMove(choice: 0)
        game3.switchPlayer()
        game3.makeMove(choice: 1)
        game3.switchPlayer()
        game3.makeMove(choice: 5)
        game3.switchPlayer()
        game3.makeMove(choice: 3)
        game3.switchPlayer()
        game3.makeMove(choice: 2)
        game3.switchPlayer()
        game3.makeMove(choice: 4)
        game3.switchPlayer()
        game3.makeMove(choice: 6)
        game3.switchPlayer()
        game3.makeMove(choice: 8)
        game3.switchPlayer()
        game3.makeMove(choice: 7)
        XCTAssert(Game.TIE_VAL == game3.gameWinner(notify: false), "Pass")
        
        game4.makeMove(choice: 0)
        game4.switchPlayer()
        game4.makeMove(choice: 1)
        game4.switchPlayer()
        game4.makeMove(choice: 5)
        game4.switchPlayer()
        game4.makeMove(choice: 3)
        game4.switchPlayer()
        game4.makeMove(choice: 2)
        game4.switchPlayer()
        game4.makeMove(choice: 4)
        game4.switchPlayer()
        game4.makeMove(choice: 6)
        game4.switchPlayer()
        game4.makeMove(choice: 8)
        XCTAssert(Game.EMPTY_VAL == game4.gameWinner(notify: false), "Pass")
    }
    
    func checkForRow() {
        let game = Game()
        game.makeMove(choice: 0)
        game.makeMove(choice: 1)
        game.makeMove(choice: 2)
        XCTAssert(game.checkForRow(square1: 0, square2: 1, square3: 2), "Pass")
        
        game.makeMove(choice: 3)
        game.makeMove(choice: 4)
        game.switchPlayer()
        game.makeMove(choice: 5)
        XCTAssert(!game.checkForRow(square1: 3, square2: 4, square3: 5), "Pass")
    }
    
    func switchPlayer() {
        let game = Game()
        game.switchPlayer()
        XCTAssert(Game.O_VAL == game.getPlayerTurn(), "Pass")
        
        game.switchPlayer()
        XCTAssert(Game.X_VAL == game.getPlayerTurn(), "Pass")
    }
    
    func squareOccupied() {
        let game = Game()
        game.makeMove(choice: 0)
        XCTAssert(game.squareOccupied(square: 0))
        XCTAssert(!game.squareOccupied(square: 1))
    }
}
