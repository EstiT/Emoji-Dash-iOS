//
//  EndGameScene.swift
//  Emoji-Dash
//
//  Created by Esti Tweg on 2019-02-11.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class EndGameScene: SKScene{
    
    init(size: CGSize, won:Bool) {
        super.init(size: size)
        let displaySize: CGRect = UIScreen.main.bounds
        backgroundColor = SKColor(red: 37/255, green: 67/255, blue: 71/255, alpha: 1.0)
        
        // Score
        let lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 60
        lblScore.fontColor = SKColor.white
        lblScore.position = CGPoint(x: displaySize.width/2, y: displaySize.height-110)
        lblScore.horizontalAlignmentMode = .center
        lblScore.text = "Score: \(GameState.sharedInstance.score)"
        addChild(lblScore)
        
        // High Score
        let lblHighScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblHighScore.fontSize = 30
        lblHighScore.fontColor = SKColor.white
        lblHighScore.position = CGPoint(x: displaySize.width/2, y: lblScore.frame.minY-lblScore.frame.height-5)
        lblHighScore.horizontalAlignmentMode = .center
        lblHighScore.text = "High Score: \(GameState.sharedInstance.highScore)"
        addChild(lblHighScore)
        
        // Try again
        let lblTryAgain = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblTryAgain.fontSize = 30
        lblTryAgain.fontColor = SKColor.white
        lblTryAgain.position = CGPoint(x: displaySize.width/2, y: lblHighScore.frame.minY-lblHighScore.frame.height-5)
        lblTryAgain.horizontalAlignmentMode = .center
        lblTryAgain.text = "Tap To Try Again"
        addChild(lblTryAgain)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Transition back to the game on tap
        let gameScene = Game(size: size)
        gameScene.scaleMode = .resizeFill
        gameScene.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        let reveal = SKTransition.flipHorizontal(withDuration: 0.6)
        view?.presentScene(gameScene, transition: reveal)
        
    }
}
