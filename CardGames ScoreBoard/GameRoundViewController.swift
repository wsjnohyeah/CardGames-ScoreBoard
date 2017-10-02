///Users/Ethan/Desktop/Fun/Swift/Texus Holdem logger/Texus Holdem logger/RoundInfoTableViewCell.swift
//  GameRoundViewController.swift
//  Texus Holdem logger
//
//  Created by Ethan Hu on 11/03/2017.
//  Copyright © 2017 Ethan Hu. All rights reserved.
///Users/Ethan/Desktop/Fun/Swift/Texus Holdem logger/Texus Holdem logger/RoundInfoTableViewCell.swift

import UIKit

class GameRoundViewController: UITableViewController, UITextFieldDelegate {
    
    func showAlert(withMessage message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBOutlet weak var checkRecordButton: UIBarButtonItem!
    
    
    var players = Dictionary<Int, String>()
    var currentRound:Round?
    var playedGameRounds:GameRounds? {
        didSet{
            GameSaver.gameRoundsInMemory = playedGameRounds
        }
    }
    
    //Textfield delegate functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 20
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 1 : players.count
    }
    
    
    private func setStyle(textFieldTableViewCell cell: TextFieldTableViewCell, cellLabel playerName: String, cellFunction:CellFunction, cellForRowAt indexPath: IndexPath){
        cell.cellLabel.text = playerName
        cell.cellTextField.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.cellFunction = cellFunction
        cell.cellTextField.placeholder = "\(LanguageKeyStrings.getKeyString(for: "current-score")) \(currentRound!.getInitialScore(forPlayer: playerName))"
        cell.cellTextField.text = nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "endGameCell", for: indexPath)
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "scoreLogCell", for: indexPath) as! TextFieldTableViewCell //impossible to be nil, because Identifier is set.
            setStyle(textFieldTableViewCell: cell, cellLabel: "\(players[indexPath.row]!)" , cellFunction: .scoreLog, cellForRowAt: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? LanguageKeyStrings.getKeyString(for: "game-control") : LanguageKeyStrings.getKeyString(for: "round-text-field-notice")
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
            case "showRoundResult":
                for row in 0 ..< players.count {
                    if let currentRowCell = self.tableView.cellForRow(at: IndexPath(row: row, section: 1)) as? TextFieldTableViewCell {
                        let currentRowScoreChange:Int? = Int(currentRowCell.textFieldDisplay ?? "") ?? nil
                        currentRound!.computeFinalScore(withScoreChange: currentRowScoreChange ?? nil, forPlayer: players[row]!)
                    }
                }
                
                if currentRound!.allFinalScoresComputed(){
                    return true
                }
                else{
                    showAlert(withMessage: LanguageKeyStrings.getKeyString(for: "set-player-score-change"))
                    currentRound!.clearAllFinalScores()
                    return false
                }
            
            default:
                return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier{
                case "showRoundResult" :
                    if let destinationRecordTableViewController = segue.destination.contents as? RecordTableViewController{
                        let lastRoundForDisplay = GameRounds(players:players)
                        lastRoundForDisplay.addRound(round: currentRound!)
                        destinationRecordTableViewController.gameRounds = lastRoundForDisplay
                        destinationRecordTableViewController.thisTableFunction = RecordTableFunction.lastRound
                        destinationRecordTableViewController.navigationItem.title = (playedGameRounds != nil) ? "#\(playedGameRounds!.getRoundAmount() + 1) \(LanguageKeyStrings.getKeyString(for: "round")) \(LanguageKeyStrings.getKeyString(for: "info"))" : "#1 \(LanguageKeyStrings.getKeyString(for: "round")) \(LanguageKeyStrings.getKeyString(for: "info"))"
                    }
                break
                
                case "showOverallResult" :
                    if let destinationRecordTableViewController = segue.destination.contents as? RecordTableViewController{
                        destinationRecordTableViewController.gameRounds = playedGameRounds
                        destinationRecordTableViewController.thisTableFunction = RecordTableFunction.general
                        destinationRecordTableViewController.navigationItem.title = LanguageKeyStrings.getKeyString(for: "record")
                    }
                    break
                
                case "endGameConfirm":
                    if let destinationGameNameTableViewController = segue.destination.contents as? GameNameTableViewController {
                        destinationGameNameTableViewController.playedGameRounds = playedGameRounds
                    }
                
            default: break
            }
        }
    }
    
    @IBAction func backToThisFromRoundResult(_ segue:UIStoryboardSegue, sender: Any?){
        currentRound?.clearAllFinalScores()
    }
    
    @IBAction func proceedToNextRoundFromRoundResult(_ segue:UIStoryboardSegue, sender: Any?){
        if playedGameRounds == nil {
            playedGameRounds = GameRounds(players:players)
            checkRecordButton.isEnabled = true
        }
        playedGameRounds!.addRound(round: currentRound!)
        var nextRoundInitalScore = Dictionary<String, Int>()
        for (_, player) in players {
            nextRoundInitalScore[player] = currentRound!.getFinalScore(forPlayer: player)
        }
        currentRound = Round(initalScore: nextRoundInitalScore)
        self.tableView.reloadData()
        self.navigationItem.title = "#\(playedGameRounds!.getRoundAmount() + 1) \(LanguageKeyStrings.getKeyString(for: "round"))"
    }
}
