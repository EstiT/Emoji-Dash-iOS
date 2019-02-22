//
//  PointNode.swift
//  Emoji-Dash
//
//  Created by Esti Tweg on 2019-02-21.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//

import Foundation
import SpriteKit


enum PointNodeType: Int {
    case STAR = 0
    case DIAMOND = 1
}

class PointNode: GameObjectNode {
    var pointType: PointNodeType?
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        print("collided with point")
        print("\(String(describing: self.name))")
        player.physicsBody?.velocity = CGVector(dx: (player.physicsBody?.velocity.dx)!+200 , dy: (player.physicsBody?.velocity.dy)!)
        removeFromParent()
        return true
    }
    
    
}
