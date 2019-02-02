//
//  Game.swift
//  Emoji-Dash
//
//  Created by Esti Tweg on 2019-01-26.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import pop

class Game: SKScene {
    
    var player = SKNode()
    var spring = SKNode()
    let bubble = SKNode()
    var springSprite = SKSpriteNode()
    let firstGame = true
    var firstGame: Bool!
    var didSpring = false
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = UIColor.white
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.0)
        physicsWorld.contactDelegate = self
        
        addSpring()
        addPlatform(position: CGPoint(x:75, y:40), type: PlatformType.PLATFORM_GREEN)
        addPlayer()
        
        if !Utility().isKeyPresentInUserDefaults(key: "firstOpen") {
            firstGame = true
        }
        else{
            firstGame = UserDefaults.standard.bool(forKey: "firstOpen")
        }
        if firstGame {
            showOnboarding()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Create Nodes
    
    func addPlayer(){
        let sprite = SKSpriteNode(imageNamed: "smileyEmoji")
        sprite.size = CGSize(width: 45, height: 45)
        sprite.name = "player"
        
        player.addChild(sprite)
        player.position = CGPoint(x:85, y:70)
        player.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.allowsRotation = true
        player.physicsBody?.restitution = 1.0
        player.physicsBody?.friction = 0.0
        player.physicsBody?.angularDamping = 0.0
        player.physicsBody?.linearDamping = 0.0
        
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.CollisionCategoryPlayer
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask =  PhysicsCategory.CollisionCategoryPlatform
    
        addChild(player)
        
    }
    
    func addPlatform(position: CGPoint, type: PlatformType) {
        let node = PlatformNode()
        node.position = position
        node.name = "NODE_PLATFORM"
        node.platformType = type
        
        let sprite : SKSpriteNode
        if type == PlatformType.PLATFORM_BLUE {
            sprite = SKSpriteNode(imageNamed: "blueBubble")
        }
        else if type == PlatformType.PLATFORM_GREY {
            sprite = SKSpriteNode(imageNamed: "greyBubble")
        }
        else if type == PlatformType.PLATFORM_GREEN {
            sprite = SKSpriteNode(imageNamed: "greenBubble")
        }
        else {  //type == PlatformType.PLATFORM_TYPING {
            sprite = SKSpriteNode(imageNamed: "typing")
        }
        
        node.addChild(sprite)
        
        node.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.CollisionCategoryPlatform
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.allowsRotation = false
        
        addChild(node)
    }
    
    func addSpring(){
        springSprite = SKSpriteNode(imageNamed: "spring")
        springSprite.size = CGSize(width: 85, height: 30)
        springSprite.name = "spring"
        springSprite.anchorPoint = CGPoint(x: 0, y: 0)
        springSprite.zPosition = -1
        
        spring.addChild(springSprite)
        spring.position = CGPoint(x:-1, y:55)
        spring.physicsBody = SKPhysicsBody(rectangleOf: springSprite.size)
        spring.physicsBody?.isDynamic = false
        
        addChild(spring)
    }
    
    func showOnboarding(){
        let textLabel = SKLabelNode(fontNamed: "TeluguSangamMN")
        textLabel.text = "Pull back the emoji to start"
        textLabel.position = CGPoint(x: 160, y: 160)
        textLabel.fontColor = UIColor.black
        textLabel.fontSize = CGFloat(17)
        textLabel.numberOfLines = 2
        textLabel.preferredMaxLayoutWidth = 140
        
        let 👆 = SKSpriteNode(imageNamed: "pointerEmoji")
        👆.position = CGPoint(x: 120, y: 120)
        👆.size = CGSize(width: 35, height: 35)
        let actionMove = SKAction.move(to: CGPoint(x: 👆.position.x - 25, y: 👆.position.y), duration: TimeInterval(0.8))
        let wait = SKAction.wait(forDuration: 1.5)
        let actionMoveReset = SKAction.move(to: CGPoint(x: 👆.position.x , y: 👆.position.y), duration: TimeInterval(0.0))
        👆.run(SKAction.repeat(SKAction.sequence([actionMove, wait, actionMoveReset]), count: 5), completion: {
            👆.removeFromParent()
            })

        
        let rect = SKShapeNode(rect: CGRect(x: textLabel.position.x - textLabel.frame.width/2 - 10 ,
                                            y: textLabel.position.y - 10,
                                            width: textLabel.frame.width+20,
                                            height: textLabel.frame.height+20))
        rect.strokeColor = UIColor(red:0.40, green:0.94, blue:0.84, alpha:1.0)
        rect.glowWidth = 1.0
//        rect.fillColor = UIColor(red:0.94, green:0.85, blue:0.40, alpha:1.0)
        
        bubble.addChild(👆)
        bubble.addChild(rect)
        bubble.addChild(textLabel)
        addChild(bubble)
        
        UserDefaults.standard.set(false, forKey: "firstOpen")
    }
    

    
    // MARK: Handle Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
//            print(node.name ?? "??")
            if node.name == "spring" {
                print("Hello")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        bubble.removeFromParent()
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            print("ended")
            print(node.name ?? "??")
            print(node)
            if node.name == "player" || node.name == "spring" {
                print("width: \(springSprite.frame.width)")
                print("x: \(player.position.x)")
                let expand = SKAction.resize(toWidth: 89.0, duration: TimeInterval(0.3))
                let retract = SKAction.resize(toWidth: 85.0, duration: TimeInterval(0.3))
                springSprite.run(SKAction.sequence([expand, retract]))//SKAction.sequence([expand, retract])
                player.run(SKAction.move(to: CGPoint(x: player.position.x + 200, y: player.position.y), duration: TimeInterval(0.5)))
                didSpring = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
//            print(node.name ?? "??")
            if node.name == "player" && !didSpring{
                let previousPosition = touch.previousLocation(in: self)
                let translation = CGPoint(x: location.x - previousPosition.x, y: location.y - previousPosition.y)
                slidePlayer(translation: translation, selectedNode: node)
                scrunchSpring(translation: translation)
            }
        }
    }
    
    func scrunchSpring(translation: CGPoint) {
        springSprite.size = CGSize(width: max(springSprite.frame.width - abs(translation.x), 45), height: springSprite.frame.height)
    }
    
    func slidePlayer(translation: CGPoint, selectedNode: SKNode) {
        let position = selectedNode.position
        selectedNode.position = CGPoint(x: max(position.x - abs(translation.x), -45), y: position.y )
    }
    
    
}

struct PhysicsCategory {
    static let CollisionCategoryPlayer   : UInt32  = 0x1 << 0  //0 single 32-bit integer, acting as a bitmask
    static let CollisionCategoryPlatform   : UInt32 =  0x1 << 1     // 1
}

extension Game: SKPhysicsContactDelegate {
    //called whenever there is a collision and contactTestBitMasks are correctly set
    func didBegin(_ contact: SKPhysicsContact) { //contact delegate method implementation
        var updateHUD = true
        
        let other = ((contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node) as! GameObjectNode
        
        updateHUD = other.collisionWithPlayer(player: player)
        
        // Update the HUD if necessary
//        if (updateHUD) {
//            scoreLabel.text = String(GameState.sharedInstance.score)
//            starLabel.text = String(GameState.sharedInstance.stars)
//        }
        
    }
    
    
    
}
