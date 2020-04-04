//
//  GameState.swift
//  Emoji-Dash
//
//  Created by Esti Tweg on 2019-02-02.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//
//  Followed Ray Wenderlich tutorial in Objective-C by Toby Stephens
//  https://www.raywenderlich.com/2467-how-to-make-a-game-like-mega-jump-with-sprite-kit-part-2-2


import Foundation
import SpriteKit

class GameState: NSObject{
    
    var score: Int
    var highScore: Int
    var level: Int
    
    static var sharedInstance = GameState()
    
    
    override init(){
        
        // Load game state
        let defaults = UserDefaults.standard
        
        highScore = defaults.object(forKey: "highScore") as? Int ?? 0
        score = 0
        level = 1
        super.init()
    }
    
    func saveState(){
        let defaults = UserDefaults.standard
        
        defaults.set(false, forKey: "firstOpen")
        
        highScore = max(score, highScore)
        // Store in user defaults
        defaults.set(NSNumber(value: highScore), forKey: "highScore")
        UserDefaults.standard.synchronize()
        
    }
    
}
