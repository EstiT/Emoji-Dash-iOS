//
//  PlatformNode.swift
//  Emoji-Dash
//
//  Created by Esti Tweg on 2019-01-27.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//

import Foundation
import SpriteKit


enum PlatformType: Int {
    case PLATFORM_GREEN = 0
    case PLATFORM_GREY = 1
    case PLATFORM_BLUE = 2
    case PLATFORM_TYPING = 3
}

class PlatformNode: GameObjectNode {
    var platformType: PlatformType?
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        if (player.physicsBody?.velocity.dy)! < CGFloat(0) { //falling
            player.physicsBody?.velocity = CGVector(dx: (player.physicsBody?.velocity.dx)!, dy: 50) //boost
        }
        return false
    }
    
    
}
