//
//  GameObjectNode.swift
//  Emoji-Dash
//
//  Created by Esti Tweg on 2019-01-27.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//

import Foundation
import SpriteKit

class GameObjectNode: SKNode {
    
    // Called when a player physics body collides with the game object's physics body
    func collisionWithPlayer(player: SKNode) -> Bool{
        return false;
    }
    
    // Called every frame to see if the game object should be removed from the scene
    func checkNodeRemoval(playerX: CGFloat){
        if playerX > self.position.x + 300.0 {
            removeFromParent();
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Collision")
    }
    
}
