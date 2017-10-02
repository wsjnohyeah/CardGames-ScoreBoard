//
//  RecordTableViewController.swift
//  Texus Holdem logger
//
//  Created by Ethan Hu on 12/03/2017.
//  Copyright © 2017 Ethan Hu. All rights reserved.
//

import UIKit

class RecordTableViewController: UITableViewController {
    var gameRounds:GameRounds?
    var thisTableFunction:RecordTableFunction?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return gameRounds?.getRoundAmount() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameRounds!.players.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultDisplayCell", for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let currentPlayer = gameRounds!.players[indexPath.row]!
        let currentRound = gameRounds!.rounds[indexPath.section]
        cell.textLabel?.text = currentPlayer
        cell.detailTextLabel?.text = "\(LanguageKeyStrings.getKeyString(for: "start")): \(currentRound.getInitialScore(forPlayer: currentPlayer))  \(LanguageKeyStrings.getKeyString(for: "change")): \(currentRound.getFinalScore(forPlayer: currentPlayer) - currentRound.getInitialScore(forPlayer: currentPlayer))  \(LanguageKeyStrings.getKeyString(for: "end")): \(currentRound.getFinalScore(forPlayer: currentPlayer))"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch thisTableFunction! {
            case .lastRound:
                return LanguageKeyStrings.getKeyString(for: "this-round-record")
            case .general:
                return "#\(section + 1) \(LanguageKeyStrings.getKeyString(for: "round")) \(LanguageKeyStrings.getKeyString(for: "info"))"
        }
    }
    
    func showAlert(withMessage message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tableFunc = thisTableFunction {
            if tableFunc == .lastRound {
                if let lastRound = gameRounds?.rounds[0] {
                    if !lastRound.checkIfScoreChangeIsConservative() {
                        showAlert(withMessage: LanguageKeyStrings.getKeyString(for: "change-not-zero-alert"))
                    }
                }
            }
        }
    }
    
}

enum RecordTableFunction {
    case lastRound
    case general
}
