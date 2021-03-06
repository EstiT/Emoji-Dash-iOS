//
//  GameScene.swift
//  Emoji-Dash
//
//  Created by Esti Tweg on 2019-01-23.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//EmojiDashLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            let fadeIn = SKAction.fadeIn(withDuration: 1.5)
            label.run(fadeIn, completion: {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.6)//fade(withDuration: 0.5)
                let game = Game(size: self.size)
                game.scaleMode = .resizeFill
                self.view?.presentScene(game, transition: reveal)
                })
            
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
