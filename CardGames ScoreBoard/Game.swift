//
//  GameRound.swift
//  Texus Holdem logger
//
//  Created by Ethan Hu on 11/03/2017.
//  Copyright © 2017 Ethan Hu. All rights reserved.
//

import Foundation

class GameSaver {
    static var gameRoundsInMemory:GameRounds?
    
    static let userDefaults = UserDefaults.standard
    static func saveGame(){
        if let playedGamedRounds = gameRoundsInMemory {
            let rounds = playedGamedRounds.rounds
            let players = playedGamedRounds.players
            let databaseIdentifier = playedGamedRounds.databaseIdentifier
            let gameName = playedGamedRounds.gameName
            
            if let databaseLocationKey = databaseIdentifier {
                let currentTime = Date()
                
                var loggedRounds = [LoggedRound]()
                for round in rounds {
                    loggedRounds.append(LoggedRound(initialScore: round.initialScore, finalScore: round.convertFinalScoreToNonOptional()))
                }
                
                let savedGame = LoggedGame(loggedRounds: loggedRounds, date: currentTime, players: players, gameName: gameName)
                
                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: savedGame)
                userDefaults.set(encodedData, forKey: "\(databaseLocationKey)")
                userDefaults.synchronize()
            }
            else {
                let currentTime = Date()
                
                var loggedRounds = [LoggedRound]()
                for round in rounds {
                    loggedRounds.append(LoggedRound(initialScore: round.initialScore, finalScore: round.convertFinalScoreToNonOptional()))
                }
                
                let savedGame = LoggedGame(loggedRounds: loggedRounds, date: currentTime, players: players, gameName: gameName)
                let keyStringIntList = userDefaults.getKeyStringIntValueWhereKeyIsInt()
                let nextLargestIndex = (keyStringIntList.max() != nil) ? keyStringIntList.max()! + 1 : 0
                
                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: savedGame)
                userDefaults.set(encodedData, forKey: "\(nextLargestIndex)")
                userDefaults.synchronize()
            }
        }
    }
    
    static func convertLoggedRoundToNextRound(for loggedRound: LoggedRound) -> Round {
        return Round(initalScore: loggedRound.finalScore)
    }
    
    static func convertLoggedRoundToPlayedRound(for loggedRound: LoggedRound) -> Round{
        let round = Round(initalScore: loggedRound.initialScore)
        round.finalScore = loggedRound.finalScore
        return round
    }
    
    static func convertLoggedGameToGameRounds(for loggedGame:LoggedGame) -> GameRounds{
        let gameRounds = GameRounds(players: loggedGame.players)
        for loggedRound in loggedGame.loggedRounds {
            gameRounds.addRound(round: self.convertLoggedRoundToPlayedRound(for: loggedRound))
        }
        gameRounds.gameName = loggedGame.gameName
        return gameRounds
    }
}

class LoggedGame:NSObject, NSCoding {
    var loggedRounds:[LoggedRound]
    var date:Date
    var players:[Int:String]
    var gameName:String
    
    init(loggedRounds:[LoggedRound], date:Date, players:[Int:String], gameName:String){
        self.loggedRounds = loggedRounds
        self.date = date
        self.players = players
        self.gameName = gameName
    }
    
    required convenience init(coder aDecoder: NSCoder){
        let date = aDecoder.decodeObject(forKey: "date") as! Date
        let loggedRounds = aDecoder.decodeObject(forKey: "loggedRounds") as! [LoggedRound]
        let players = aDecoder.decodeObject(forKey: "players") as! [Int:String]
        let gameName = aDecoder.decodeObject(forKey: "gameName") as! String
        self.init(loggedRounds: loggedRounds, date: date, players: players, gameName: gameName)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(loggedRounds, forKey: "loggedRounds")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(players, forKey: "players")
        aCoder.encode(gameName, forKey:"gameName")
    }
}

class LoggedRound: NSObject, NSCoding{
    var initialScore: [String:Int]
    var finalScore: [String:Int]
    
    init(initialScore:[String:Int], finalScore:[String:Int]) {
        self.initialScore = initialScore
        self.finalScore = finalScore
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let initialScore = aDecoder.decodeObject(forKey: "initialScore") as! [String:Int]
        let finalScore = aDecoder.decodeObject(forKey: "finalScore") as! [String:Int]
        self.init(initialScore: initialScore, finalScore: finalScore)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(initialScore, forKey: "initialScore")
        aCoder.encode(finalScore, forKey: "finalScore")
    }
    
}

class GameRounds{
    let players:[Int:String]
    var rounds = Array<Round>()
    var databaseIdentifier:Int?
    var gameName = LanguageKeyStrings.getKeyString(for: "un-named-game")
    
    init(players:[Int:String]){
        self.players = players
    }
    
    func getRoundAmount() -> Int{
        return rounds.count
    }
    
    func addRound(round: Round){
        rounds.append(round)
    }
    
}

class Round{
    var initialScore: Dictionary<String,Int>
    var finalScore = Dictionary<String,Int?>()
    
    init(initalScore:Dictionary<String,Int>) {
        self.initialScore = initalScore
    }
    
    func getInitialScore(forPlayer player:String) -> Int {
        return initialScore[player]!
    }
    
    func getFinalScore(forPlayer player:String) -> Int {
        return finalScore[player]!!
    }
    
    func computeFinalScore(withScoreChange scoreChange:Int?, forPlayer player:String){
        if let playerInitialScore = initialScore[player] {
            finalScore[player] = (scoreChange != nil) ? playerInitialScore + scoreChange! : nil
        }
    }
    
    func convertFinalScoreToNonOptional() -> [String:Int]{
        var nonOptionalFinalScore = [String:Int]()
        for (player, score) in finalScore {
            nonOptionalFinalScore[player] = score!
        }
        return nonOptionalFinalScore
    }
    
    func allFinalScoresComputed() -> Bool {
        var allComputed = true
        for (_, score) in finalScore {
            if score == nil {
                allComputed = false
                break
            }
        }
        return allComputed
    }
    
    func clearAllFinalScores(){
        for (player, _) in finalScore {
            finalScore[player] = nil
        }
    }
    
    func checkIfScoreChangeIsConservative() -> Bool {
        var initialScoreSum = 0
        var finalScoreSum = 0
        for (_, score) in initialScore {
            initialScoreSum += score
        }
        for (_, score) in finalScore {
            finalScoreSum += score! //WARNING: A Dangerous Force Unwrap
        }
        return (initialScoreSum == finalScoreSum) ? true : false
    }
}
