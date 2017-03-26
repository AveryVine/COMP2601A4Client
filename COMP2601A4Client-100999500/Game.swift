//
//  Game.swift
//  COMP2601A4Client-100999500
//
//  Created by Alexei Tipenko on 2017-03-26.
//  Copyright © 2017 Avery Vine. All rights reserved.
//

import Foundation

class Game {
    
    static var X_VAL = 1, O_VAL = 2, TIE_VAL = 3, EMPTY_VAL = 0
    
    private var board = Array(repeating: 0, count: 9)
    private var playerTurn: Int
    private var active: Bool
    
    private var observerArray = [Observer]()
    
    
    
    /*----------
     - Description: constructor for the game
     - Input: none
     - Return: none
     ----------*/
    init() {
        active = true;
        playerTurn = Game.X_VAL
    }
    
    
    
    /*----------
     - Description: observable function that attaches an observer to the Game
     - Input: the observer to be attached
     - Return: none
     ----------*/
    func attachObserver(observer : Observer) {
        observerArray.append(observer)
    }
    
    
    
    /*----------
     - Description: observable function that notifies all observers that a move was made
     - Input: the position of the move
     - Return: none
     ----------*/
    private func notifyMove(choice: Int) {
        for observer in observerArray {
            observer.updateMove(choice: choice)
        }
    }
    
    
    
    /*----------
     - Description: observable function that notifies all observers that the game is over
     - Input: the winner of the game
     - Return: none
     ----------*/
    private func notifyGameWinner(winner: Int) {
        for observer in observerArray {
            observer.updateGameWinner(winner: winner)
        }
    }
    
    
    
    /*----------
     - Description: select a random unoccupied square to make a move in
     - Input: whether computer AI is enabled or not
     - Return: the selected square
     ----------*/
    func randomSquare(switchAI: Bool) -> Int {
        var choice = -1
        if playerTurn == Game.O_VAL && switchAI {
            choice = bestMove(lastBoard: board, lastPlayerTurn: Game.X_VAL)
        }
        else {
            repeat {
                choice = Int(arc4random_uniform(UInt32(9)))
            } while (board[choice] != Game.EMPTY_VAL)
        }
        return choice;
    }
    
    
    
    /*----------
     - Description: makes a move for the current player at the given square
     - Input: choice of square
     - Return: none
     ----------*/
    func makeMove(choice: Int) {
        board[choice] = playerTurn;
        notifyMove(choice: choice)
    }
    
    
    
    /*----------
     - Description: tries to make a good move using the minimax algorithm
     - Input: a potential iteration of the board, the last player to have played in that iteration
     - Return: none
     - Notes on Computer AI:
     - The computer AI makes use of the minimax algorithm, which recursively assigns values to each potential end game
     - It assigns 10 points for a computer win, -10 points for a human win, and 0 points for a tie
     - It takes that score and bumps it down the stack until it reaches the actual current state of the board
     - It then chooses the move with the overall best total score
     - Credit to http://neverstopbuilding.com/minimax for the algorithm and explanation
     ----------*/
    func bestMove(lastBoard: [Int], lastPlayerTurn: Int) -> Int {
        let winner = gameWinner(currBoard: lastBoard, currPlayerTurn: lastPlayerTurn)
        var nextPlayerTurn: Int
        if lastPlayerTurn == 1 {
            nextPlayerTurn = 2
        }
        else {
            nextPlayerTurn = 1
        }
        if winner != Game.EMPTY_VAL {
            if winner == Game.O_VAL { return 10 }
            else if winner == Game.X_VAL { return -10 }
            return 0
        }
        var scores = [Int]()
        var moves = [Int]()
        for i in 0 ..< 9 {
            if lastBoard[i] == Game.EMPTY_VAL {
                var possibleBoard = lastBoard
                possibleBoard[i] = nextPlayerTurn
                scores.append(bestMove(lastBoard: possibleBoard, lastPlayerTurn: nextPlayerTurn))
                moves.append(i)
            }
        }
        if nextPlayerTurn == playerTurn {
            if board == lastBoard {
                return moves[scores.index(of: scores.max()!)!]
            }
            return scores.max()!
        }
        else {
            if board == lastBoard {
                return moves[scores.index(of: scores.min()!)!]
            }
            return scores.min()!
        }
    }
    
    
    
    /*----------
     - Description: checks to see if anyone has won the game, or if the game has resulted in a tie
     - Input: the board to be tested for a winner, the last player to have made a move on the board
     - Return: 1 (X wins), 2 (O wins), 3 (tie), or 0 (game not over)
     ----------*/
    func gameWinner(currBoard: [Int], currPlayerTurn: Int) -> Int {
        if (checkForRow(square1: 0, square2: 1, square3: 2, currBoard: currBoard)
            || checkForRow(square1: 3, square2: 4, square3: 5, currBoard: currBoard)
            || checkForRow(square1: 6, square2: 7, square3: 8, currBoard: currBoard)
            || checkForRow(square1: 0, square2: 3, square3: 6, currBoard: currBoard)
            || checkForRow(square1: 1, square2: 4, square3: 7, currBoard: currBoard)
            || checkForRow(square1: 2, square2: 5, square3: 8, currBoard: currBoard)
            || checkForRow(square1: 0, square2: 4, square3: 8, currBoard: currBoard)
            || checkForRow(square1: 2, square2: 4, square3: 6, currBoard: currBoard)) {
            if (currBoard == board) {
                notifyGameWinner(winner: currPlayerTurn)
            }
            return currPlayerTurn;
        }
        for i in 0 ..< 9 {
            if (currBoard[i] == Game.EMPTY_VAL) {
                return Game.EMPTY_VAL;
            }
        }
        if (currBoard == board) {
            notifyGameWinner(winner: Game.TIE_VAL)
        }
        return Game.TIE_VAL;
    }
    
    
    
    /*----------
     - Description: checks to see if the provided row is complete
     - Input: the three squares in question, the board to be tested for a row
     - Return: complete or not complete
     ----------*/
    func checkForRow(square1: Int, square2: Int, square3: Int, currBoard: [Int]) -> Bool {
        if (currBoard[square1] == currBoard[square2]
            && currBoard[square1] == currBoard[square3]
            && currBoard[square1] != Game.EMPTY_VAL) {
            return true;
        }
        return false;
    }
    
    
    
    /*----------
     - Description: switches the active player
     - Input: none
     - Return: none
     ----------*/
    func switchPlayer() {
        playerTurn = (playerTurn == Game.X_VAL ? Game.O_VAL : Game.X_VAL);
    }
    
    
    
    /*----------
     - Description: checks to see if the provided square is occupied
     - Input: the square to check
     - Return: occupied or not occupied
     ----------*/
    func squareOccupied(square: Int) -> Bool {
        return (board[square] == Game.EMPTY_VAL) ? false : true;
    }
    
    
    
    /*----------
     - Description: getters
     - Input: none
     - Return: various properties of Game
     ----------*/
    func getPlayerTurn() -> Int { return playerTurn }
    func getActive() -> Bool { return active }
    func toggleActive() { active = !active }
    func getSquare(choice: Int) -> Int { return board[choice] }
    func getBoard() -> [Int] { return board }
    
    /*----------
     - Description: prints the current state of the board (for debugging only)
     - Input: none
     - Return: none
     ----------*/
    func printBoard(tempBoard: [Int]) {
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                print("\(tempBoard[i * 3 + j]) \t")
            }
            print("\n");
        }
    }
}
