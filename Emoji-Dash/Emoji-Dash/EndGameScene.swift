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
        lblScore.fontSize = 55
        lblScore.fontColor = SKColor.white
        lblScore.position = CGPoint(x: displaySize.maxX/2, y: displaySize.maxY-110)
        lblScore.horizontalAlignmentMode = .center
        lblScore.text = "Score: \(GameState.sharedInstance.score)"
        addChild(lblScore)
        
        // High Score
        let lblHighScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblHighScore.fontSize = 30
        lblHighScore.fontColor = SKColor.white
        lblHighScore.position = CGPoint(x: displaySize.maxX/2, y: lblScore.frame.minY-lblScore.frame.height-5)
        lblHighScore.horizontalAlignmentMode = .center
        lblHighScore.text = "High Score: \(GameState.sharedInstance.highScore)"
        addChild(lblHighScore)
        
        // Try again
        let lblTryAgain = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblTryAgain.fontSize = 30
        lblTryAgain.fontColor = SKColor.white
        lblTryAgain.position = CGPoint(x: displaySize.maxX/2, y: 50)
        lblTryAgain.horizontalAlignmentMode = .center
        if GameState.sharedInstance.level == 1 {
            lblTryAgain.text = "Tap To Try Again"
        }
        else if GameState.sharedInstance.level == 2{
            lblTryAgain.text = "Tap To Go to Level 2"
        }
        
        addChild(lblTryAgain)
        
        let pulseUp = SKAction.scale(to: 1.05, duration: 0.8)
        let pulseDown = SKAction.scale(to: 0.95, duration: 0.8)
        lblTryAgain.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
        
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
