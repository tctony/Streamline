//
//  GameState.swift
//  Streamline
//
//  Created by Chongbin (Bob) Zhang on 2019/7/31.
//  Copyright © 2019 Xuezheng Wang. All rights reserved.
//

import Foundation

public class GameState {
    // Used to populate char[][] board below and to display the
    // current state of play.
    let TRAIL_CHAR: Character = ".";
    let OBSTACLE_CHAR: Character = "X";
    let SPACE_CHAR: Character = " ";
    let CURRENT_CHAR: Character = "O";
    let GOAL_CHAR: Character = "@";
    let NEWLINE_CHAR: Character = "\n";
    let UD_BORDER_CHAR: Character = "-"; // upper and lower of toString()
    let SIDE_BORDER_CHAR: Character = "|"; // side border for toString()
    
    // used to format the toString() method about the upper & lower border's
    // length
    let BORDER_MULTIPLIER = 2;
    let BORDER_APPENDER = 3;
    
    // how many rotation required to return to the original status
    let rotate360 = 4;
    
    // This represents a 2D map of the board
    var board: [[Character]];
    
    // Location of the player
    var playerRow: Int;
    var playerCol: Int;
    
    // Location of the goal
    var goalRow: Int;
    var goalCol: Int;
    
    // true means the player completed this level
    var levelPassed: Bool;
    
    /** Constructor: GameState
     * Will initialize a board of given parameters
     * And fill the board with SPACE_CHAR
     * Those corresponding fields will be set to parameters.
     * If the goal or player position is off the board will terminate the
     *     method and tell the user to change another input.
     * */
    public init (height: Int, width: Int, playerRow: Int, playerCol: Int, goalRow: Int, goalCol: Int) {
        if (playerRow >= height || playerCol >= width) {
            print("Please enter a valid player position that is not off the board. \n");
            return;
        }
        else if (goalRow >= height || goalCol >= width) {
            print("Please enter a valid goal position that is not off the board. \n");
            return;
        }
        else if (goalRow == playerRow && goalCol == playerCol) {
            print("Please enter a valid goal position that does not overlap the player. \n");
            return;
        }
        else {
            self.board = [[]]
            for i in 0...height {
                for j in 0...width {
                    self.board[i][j] = SPACE_CHAR
                }
            } // TODO: how to initialize it with space_char?
            self.playerRow = playerRow; // self refers to this in Java
            self.playerCol = playerCol;
            self.goalRow = goalRow;
            self.goalCol = goalCol;
            self.levelPassed = (playerCol == goalCol) && (playerRow == goalRow);
        }
    }
    
    /** Copier: GameState (the second constructor method in this class)
     * Will copy whatever the state of another board is
     * Deep copy that will loop through every element in the array to
     *     populate a new array for the char[][] board
     * */
    public init (other: GameState) {
        self.playerRow = other.playerRow;
        self.playerCol = other.playerCol;
        self.goalRow = other.goalRow;
        self.goalCol = other.goalCol;
        self.levelPassed = other.levelPassed; // checkpoint edge case
        self.board = [[]]
        for i in 0...other.board.count {
            for j in 0...other.board[0].count {
                self.board[i][j] = other.board[i][j];
            }
        }
    }
    
    /** Method: addRandomObstacles
     * add count-many of random blocks into this.board
     * the player should stop moving when ran into it
     * @param count: how many obstacles we want to put onto the board
     * Will check if count exceeds the number of empty spaces
     * Will check if it is an occupied place, i.e. player, goal or already
     *     have something in the block
     * */
    public func addRandomObstacles(count: Int) {
        var empty = 0;
        for i in 0...self.board.count {
            for j in 0...self.board[0].count {
                if (board[i][j] != TRAIL_CHAR && board[i][j] != OBSTACLE_CHAR) {
                    if (i == playerRow && j == playerCol) {
                        continue
                    }
                    if (i == goalRow && j == goalCol) {
                        continue
                    }
                    empty += 1;
                }
            }
        } // count how many empty places are remaining on the board
        if (count > empty) {
            print("Please enter a number no greater than the amount empty spaces on the board. ");
            print("count: \(count), empty: \(empty)")
            return;
        }
        else {
            var total = 0;
            while (total < count) {
                let randRow = Int.random(in: 0 ..< self.board.count);
                let randCol = Int.random(in: 0 ..< self.board[0].count);
                // set up random int no greater than width & height
                if (self.board[randRow][randCol] != TRAIL_CHAR && self.board[randRow][randCol] != OBSTACLE_CHAR) {
                    if (randRow == playerRow && randCol == playerCol) {
                        continue;
                    }
                    if (randRow == goalRow && randCol == goalCol) {
                        continue;
                    }
                    self.board[randRow][randCol] = OBSTACLE_CHAR;
                    total += 1;
                } // as long as it's empty we can set an obstacle
            }
        }
    }
    
    /** Method: rotateClockwise
     * Will rotate everything on the playing board clockwise once, including
     *     player's, goal's and obstacles' position
     * */
    public func rotateClockwise() {
        let origH = self.board.count;
        let origW = self.board[0].count;
        var rotated: [[Character]] = [[]];
        for i in 0...origW {
            for j in 0...origH {
                rotated[i][j] = self.board[origH - j - 1][i];
            }
        }
        let newPC = origH - self.playerRow - 1;
        let newPR = self.playerCol;
        let newGC = origH - self.goalRow - 1;
        let newGR = self.goalCol;
        
        self.playerCol = newPC;
        self.playerRow = newPR;
        self.goalCol = newGC;
        self.goalRow = newGR;
        self.board = rotated;
    }
    
    
    /** Method: moveRight
     * First check if the player has passed the level or not, if so
     *     will print a message saying so and stop from further moving
     * Keep moving the player's position to the right, i.e. adding its column
     *     index as long as there's nothing in the next block
     * If the player meets the goal at some time in the middle, will return
     *     directly from the game
     * */
    public func moveRight() {
        if (self.levelPassed == true) {
            print("You've passed this level, there's no need to keep moving. ");
            return;
        }
        else {
            let nowRow = self.playerRow;
            var nowCol = self.playerCol;
            while ((nowCol + 1 < self.board[nowRow].count) && (self.board[nowRow][nowCol + 1] != OBSTACLE_CHAR) && (self.board[nowRow][nowCol + 1] != TRAIL_CHAR)) {
                self.board[nowRow][nowCol] = TRAIL_CHAR;
                nowCol += 1;
                if (nowRow == self.goalRow && nowCol == self.goalCol) {
                    self.levelPassed = true;
                    self.playerCol = nowCol;
                    return;
                }
                self.playerCol = nowCol;
            }
        }
    }
    
    public func move() {
        
    }
    
    public func toString() {
        
    }
    
    public func equals(other: GameState) {
        
    }
}
