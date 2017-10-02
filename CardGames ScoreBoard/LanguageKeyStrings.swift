//
//  LanguageKeyStrings.swift
//  Poker Log
//
//  Created by Ethan Hu on 20/03/2017.
//  Copyright © 2017 Ethan Hu. All rights reserved.
//

import Foundation

class LanguageKeyStrings {
    private static let language = Locale.current.languageCode!
    
    static func getKeyString (for key:String) -> String{
        switch language {
            case "zh":
                return chineseKeyStrings[key] ?? key
            case "en":
                return englishKeyStrings[key] ?? key
            default:
                return englishKeyStrings[key] ?? key
        }
    }
    
    private static let englishKeyStrings = [
        "initial-score" : "Initial Scores",
        "player-amount" : "Number of Players",
        "player" : "Player",
        "name" : "Name",
        "current-score" : "Current Score: ",
        "round" : "Round",
        "info" : "Info",
        "start" : "Start",
        "change" : "Change",
        "end" : "End",
        "record" : "Record",
        "round-text-field-notice" : "Score Change. Keep an Eye On The Sign",
        "basic-settings" : "Basic Settings",
        "player-name-settings" : "Player Name Settings",
        "set-initial-score-for-player" : "Please set the inital score for each player",
        "set-name-for-player" : "Please set all the player names",
        "set-player-amount" : "Please set the number of players",
        "set-player-score-change" : "Please set score changes for all players",
        "this-round-record" : "Record For This Round",
        "game-history-data" : "Game Records",
        "last-at" : "Last At",
        "players" : "Players",
        "played" : "Played",
        "rounds" : "Rounds",
        "end-game-setting" : "End-Game Settings",
        "un-named-game" : "Un-Named Game",
        "change-not-zero-alert" : "The sum of changes in scores for all players does not equal to 0. Go Back and check your input if this matters.",
        "no-rename-alert" : "Please don't enter the same name multiple times.",
        "game-control" : "Game Control",
        "game-history-no-data" : "No Game Data Yet! Start a new game!",
    ]
    
    private static let chineseKeyStrings = [
        "initial-score" : "初始分数",
        "player-amount" : "玩家数量",
        "player" : "玩家",
        "name" : "名称",
        "current-score" : "当前分数: ",
        "round" : "轮",
        "info" : "信息",
        "start" : "开始",
        "change" : "变化",
        "end" : "结束",
        "record" : "历史数据",
        "round-text-field-notice" : "玩家该轮内分数变化，注意正负号",
        "basic-settings" : "基本设定",
        "player-name-settings" : "玩家名称设定",
        "set-initial-score-for-player" : "请给每个玩家设置初始分数",
        "set-name-for-player" : "请给所有玩家设置名称",
        "set-player-amount" : "请设置玩家数量",
        "set-player-score-change" : "请设置所有玩家的分数变化",
        "this-round-record" : "本轮数据",
        "game-history-data" : "游戏历史数据",
        "last-at" : "最后于",
        "players" : "玩家",
        "played" : "玩了",
        "rounds" : "轮",
        "end-game-setting" : "结束游戏设置",
        "un-named-game" : "未命名的游戏",
        "change-not-zero-alert" : "当前回合所有玩家分数变化之和不为0。如果这不符合你的游戏规则，请返回并查看你的输入",
        "no-rename-alert" : "请不要重名！",
        "game-control" : "游戏控制",
        "game-history-no-data" : "无游戏历史数据，开始新游戏吧！",

    ]
}
