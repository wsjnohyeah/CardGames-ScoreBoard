//
//  GameConfigureViewController.swift
//  Texus Holdem logger
//
//  Created by Ethan Hu on 09/03/2017.
//  Copyright © 2017 Ethan Hu. All rights reserved.
//

import UIKit

extension UIViewController {
    var contents: UIViewController { // check if is a navigation controller, if is, return the top viewcontroller that navigation controller contains
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        }
        else {
            return self
        }
    }
}

class GameConfigureViewController: UITableViewController, UITextFieldDelegate{
    
    @IBOutlet weak var gameStartButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameStartButton.isEnabled = false;
    }
    
    //delegate Function for Text Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if let superTableCellView = textField.superview?.superview as? TextFieldTableViewCell{
            if let cellFunction = superTableCellView.cellFunction {
                switch cellFunction {
                    case .playerNumber, .initalScore:
                        let newPlayerNumber = Int((self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell)?.textFieldDisplay ?? "") ?? nil
                        if playerNumber != newPlayerNumber {
                            playerNumber = newPlayerNumber != nil ? max(2, min(50,newPlayerNumber!)) : newPlayerNumber
                        }
                        break
                    default:
                        break
                }
            }
        }
        return false;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 30
    }
    

    private var players = Dictionary<Int, String>()
    
    private var initialScore:Int?
    
    private var playerNumber:Int?{
        didSet{
            gameStartButton.isEnabled = true
            self.tableView.reloadData()
        }
    }
    
    func showAlert(withMessage message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (playerNumber != nil) ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }
        else{
            return playerNumber! //cannot be nil if there is two sections
        }
    }
    
    
    private func setStyle(textFieldTableViewCell cell: TextFieldTableViewCell, cellLabel: String, cellFunction:CellFunction, cellForRowAt indexPath: IndexPath){
        cell.cellLabel.text = cellLabel
        cell.cellTextField.delegate = self
        cell.cellTextField.borderStyle = .none
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.cellFunction = cellFunction
        switch cellFunction {
            case .playerNumber:
                cell.cellTextField.text = (playerNumber != nil) ? "\(playerNumber!)" : nil
                break
            case .playerName:
                cell.cellTextField.text = nil
                break
            default:
                break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerNumberCell", for: indexPath) as! TextFieldTableViewCell //impossible to be nil, because Identifier is set.
                setStyle(textFieldTableViewCell: cell, cellLabel: LanguageKeyStrings.getKeyString(for: "player-amount"), cellFunction: .playerNumber, cellForRowAt: indexPath)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerNumberCell", for: indexPath) as! TextFieldTableViewCell //impossible to be nil, because Identifier is set.
                setStyle(textFieldTableViewCell: cell, cellLabel: LanguageKeyStrings.getKeyString(for: "initial-score"), cellFunction: .initalScore, cellForRowAt: indexPath)
                return cell
            }
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerNameCell", for: indexPath) as! TextFieldTableViewCell //impossible to be nil, because Identifier is set.
            setStyle(textFieldTableViewCell: cell, cellLabel: "\(LanguageKeyStrings.getKeyString(for: "player")) \(indexPath.row + 1) \(LanguageKeyStrings.getKeyString(for: "name"))", cellFunction: .playerName, cellForRowAt: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return LanguageKeyStrings.getKeyString(for: "basic-settings")
        }
        else{
            return LanguageKeyStrings.getKeyString(for: "player-name-settings")
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameRoundViewController = segue.destination.contents as? GameRoundViewController {
            gameRoundViewController.players = players
            gameRoundViewController.navigationItem.title = "#1 \(LanguageKeyStrings.getKeyString(for: "round"))"
            gameRoundViewController.checkRecordButton.isEnabled = false
            var firstRoundInitialScore = Dictionary<String,Int>()
            for (_, players) in players {
                firstRoundInitialScore[players] = initialScore!
            }
            gameRoundViewController.currentRound = Round(initalScore: firstRoundInitialScore)
        }
    }
    
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
            case "startGame":
                if self.tableView.numberOfSections == 2 {
                    let rowNumber = self.tableView.numberOfRows(inSection: 1)
                    var playerNameInfoIsValid = true
                    for row in 0 ..< rowNumber {
                        let indexPathToCell = IndexPath(row: row, section: 1)
                        let cell = self.tableView.cellForRow(at: indexPathToCell) as! TextFieldTableViewCell
                        if cell.textFieldDisplay != nil && cell.textFieldDisplay != ""{
                            for (_, name) in players {
                                if name == cell.textFieldDisplay! {
                                    players.removeAll()
                                    showAlert(withMessage: LanguageKeyStrings.getKeyString(for: "no-rename-alert"))
                                    return false;
                                }
                            }
                            players[row] = cell.textFieldDisplay!
                        }
                        else{
                            players.removeAll()
                            playerNameInfoIsValid = false
                            break
                        }
                    }
                    if playerNameInfoIsValid{
                        initialScore = Int((self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TextFieldTableViewCell)?.textFieldDisplay ?? "") ?? nil
                        if initialScore == nil {
                            showAlert(withMessage: LanguageKeyStrings.getKeyString(for: "set-initial-score-for-player"))
                            return false
                        }
                        else{
                            return true
                        }
                    }
                    else{
                        showAlert(withMessage: LanguageKeyStrings.getKeyString(for: "set-name-for-player"))
                        return false
                    }
                }
                else{
                    showAlert(withMessage: LanguageKeyStrings.getKeyString(for: "set-player-amount"))
                    return false
                }
        
            default: return true
        }
    }
    
}
