//
//  TextFiedTableViewCell.swift
//  Texus Holdem logger
//
//  Created by Ethan Hu on 10/03/2017.
//  Copyright © 2017 Ethan Hu. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell{

    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var cellLabel: UILabel!
    
    var textFieldDisplay:String?{
        return cellTextField?.text
    }
    
    var cellFunction:CellFunction?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Initialized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

enum CellFunction{
    case playerNumber
    case playerName
    case initalScore
    case scoreLog
}

