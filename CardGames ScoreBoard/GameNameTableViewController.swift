//
//  GameNameTableViewController.swift
//  Poker Log
//
//  Created by Ethan Hu on 21/03/2017.
//  Copyright © 2017 Ethan Hu. All rights reserved.
//

import UIKit

class GameNameTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var gameNameTextField: UITextField!
    
    var gameName:String? {
        get {
            return gameNameTextField.text
        }
        set {
            gameNameTextField.text = newValue
        }
    }
    
    var playedGameRounds:GameRounds? {
        didSet{
            GameSaver.gameRoundsInMemory = playedGameRounds
        }
    }
    
    /*
    * TextField Delegate Methods
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 30
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameNameTextField.delegate = self
        gameNameTextField.borderStyle = .none
        gameName = playedGameRounds?.gameName
        self.navigationItem.title = LanguageKeyStrings.getKeyString(for: "end-game-setting")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        playedGameRounds?.gameName = (gameName != nil && gameName != "") ? gameName! : LanguageKeyStrings.getKeyString(for: "un-named-game")
    }

}
