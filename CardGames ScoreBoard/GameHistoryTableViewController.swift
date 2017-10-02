//
//  GameHistoryTableViewController.swift
//  Poker Log
//
//  Created by Ethan Hu on 21/03/2017.
//  Copyright © 2017 Ethan Hu. All rights reserved.
//
extension UserDefaults {
    
    func getKeyStringIntValueWhereKeyIsInt() -> [Int] {
        var keyStringsToInt = [Int]()
        for (key, _) in self.dictionaryRepresentation() {
            if let keyInt:Int = Int(key) {
                keyStringsToInt.append(keyInt)
            }
        }
        return keyStringsToInt.sorted(by: { $0 > $1 })
    }
    
    func getArrayOfDecodedDataToLoggedGameAtIntKeys() -> [LoggedGame]{
        var loggedGameList = [LoggedGame]()
        let keyStrings = self.getKeyStringIntValueWhereKeyIsInt()
        let objectList = self.dictionaryRepresentation()
        for key in keyStrings {
            let objectToData = objectList["\(key)"] as! Data
            let imbeddedLoggedGame = NSKeyedUnarchiver.unarchiveObject(with: objectToData) as! LoggedGame
            loggedGameList.append(imbeddedLoggedGame)
        }
        return loggedGameList
    }
}


import UIKit

class GameHistoryTableViewController: UITableViewController {
    
    
    @IBAction func cancelToGameHistory(_ segue:UIStoryboardSegue, sender: Any?){
        updateLoggedGameList()
        tableView.reloadData()
    }
    
    @IBAction func unwindToGameHistory(_ segue:UIStoryboardSegue, sender: Any?){
        GameSaver.saveGame()
        updateLoggedGameList()
        tableView.reloadData()
    }
    
    func updateLoggedGameList(){
        loggedGameList = userDefaults.getArrayOfDecodedDataToLoggedGameAtIntKeys()
    }
    
    let userDefaults = UserDefaults.standard
    var loggedGameList = [LoggedGame]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLoggedGameList()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let databaseIdentifier = "\(userDefaults.getKeyStringIntValueWhereKeyIsInt()[indexPath.row])"
            userDefaults.removeObject(forKey: databaseIdentifier)
            updateLoggedGameList()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loggedGameList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameHistoryCell", for: indexPath)
        
        let currentLoggedGame = loggedGameList[indexPath.row]
        
        let playedDate = currentLoggedGame.date
        let playedDateFormatter = DateFormatter()
        playedDateFormatter.dateFormat = "yyyy-M-d HH:mm"
        playedDateFormatter.timeZone = TimeZone.current
        let dateString = playedDateFormatter.string(from: playedDate)

        let playedRounds:Int = currentLoggedGame.loggedRounds.count
        let playerNumber:Int = currentLoggedGame.players.count
        cell.textLabel?.text = currentLoggedGame.gameName
        cell.detailTextLabel?.text = "\(LanguageKeyStrings.getKeyString(for: "last-at")) \(dateString); \(playerNumber) \(LanguageKeyStrings.getKeyString(for: "players"))，\(LanguageKeyStrings.getKeyString(for: "played")) \(playedRounds) \(LanguageKeyStrings.getKeyString(for: "rounds"))"
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (loggedGameList.count != 0) ? LanguageKeyStrings.getKeyString(for: "game-history-data") : LanguageKeyStrings.getKeyString(for: "game-history-no-data")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let senderTableViewCell = sender as? UITableViewCell {
            if let destinationGameRoundViewController = segue.destination.contents as? GameRoundViewController {
                if let indexPath = tableView.indexPath(for: senderTableViewCell) {
                    
                    let currentLoggedGame = loggedGameList[indexPath.row]
                    destinationGameRoundViewController.players = currentLoggedGame.players
                    destinationGameRoundViewController.navigationItem.title = "#\(currentLoggedGame.loggedRounds.count + 1) \(LanguageKeyStrings.getKeyString(for: "round"))"
                    
                    let lastLoggedRound = currentLoggedGame.loggedRounds[currentLoggedGame.loggedRounds.count - 1]
                    destinationGameRoundViewController.currentRound = GameSaver.convertLoggedRoundToNextRound(for: lastLoggedRound)
                    
                    //Add database identifier for game
                    let playedGameRounds = GameSaver.convertLoggedGameToGameRounds(for: currentLoggedGame)
                    playedGameRounds.databaseIdentifier = userDefaults.getKeyStringIntValueWhereKeyIsInt()[indexPath.row]
                    destinationGameRoundViewController.playedGameRounds = playedGameRounds
                }
            }
        }
    }

}
