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
    var hudNode = SKNode()
    var foregroundNode = SKNode()
    
    var springSprite = SKSpriteNode()
    let 👆 = SKSpriteNode(imageNamed: "pointerEmoji")
    let onboardingText = SKLabelNode(fontNamed: "Avenir-Heavy")
    
    var scoreLabel = SKLabelNode()
    
    var firstGame: Bool!
    var gameOver: Bool = false
    var didSpring = false
    var endLevelX: Int
    var maxPlayerX: Int
    let levelPlist: String
    let levelData: NSDictionary
    
    override init(size: CGSize) {
        // Load the level
        levelPlist = Bundle.main.path(forResource: "Level01", ofType: "plist")!
        levelData = NSDictionary(contentsOfFile: levelPlist)!
        
        endLevelX = levelData["EndX"] as! Int
        maxPlayerX = 150
        
        GameState.sharedInstance.score = 0 //reset the game each time
        gameOver = false
        
        super.init(size: size)
        backgroundColor = UIColor.white
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.0)
        physicsWorld.contactDelegate = self
        
        addSpring()
        foregroundNode.addChild(createPlatformAt(position: CGPoint(x:85, y:110), type: PlatformType.PLATFORM_GREEN))
        addPlatforms()
        addPlayer()
        addChild(foregroundNode)
        addHud()
        
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
    
    // MARK: Player
    
    func addPlayer(){
        let sprite = SKSpriteNode(imageNamed: "smileyEmoji")
        sprite.size = CGSize(width: 45, height: 45)
        sprite.name = "player"
        sprite.zPosition = 3
        
        player.addChild(sprite)
        player.position = CGPoint(x:85, y:140)
        player.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.allowsRotation = true
        player.physicsBody?.restitution = 0.7
        player.physicsBody?.friction = 0.0
        player.physicsBody?.angularDamping = 0.0
        player.physicsBody?.linearDamping = 0.0
        
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.CollisionCategoryPlayer
        player.physicsBody?.collisionBitMask = PhysicsCategory.CollisionCategoryPlatform | PhysicsCategory.CollisionCategoryPoint
        player.physicsBody?.contactTestBitMask =  PhysicsCategory.CollisionCategoryPoint | PhysicsCategory.CollisionCategoryDevil
    
        addChild(player)
        
    }
    
    // MARK: Platforms
    
    func addPlatforms(){
        if let platforms = levelData["Platforms"] as? [AnyHashable : Any] {
            if let platformPatterns = platforms["Patterns"] as? [AnyHashable : Any]{
                if let platformPositions = platforms["Positions"] as? [Any]{
                    
                    for platformPosition: [AnyHashable : Any]? in platformPositions as? [[AnyHashable : Any]?] ?? [] {
                        let patternX =  CGFloat(((platformPosition?["x"] as? NSNumber)?.floatValue)!)
                        let patternY =  CGFloat(((platformPosition?["y"] as? NSNumber)?.floatValue)!)
                        let pattern = platformPosition?["pattern"] as! String
                        
                        // Look up the pattern
                        if let platformPattern = platformPatterns[pattern] as? NSArray{
                            for platformPoint: [AnyHashable : Any]? in platformPattern as! [[AnyHashable : Any]?] {
                                let x = CGFloat(((platformPoint?["x"] as? NSNumber)?.floatValue)!)
                                let y = CGFloat(((platformPoint?["y"] as? NSNumber)?.floatValue)!)
                                if let type = platformPoint?["type"] as? Int{
                                    let platformNode: PlatformNode? = createPlatformAt(position: CGPoint(x: x + patternX, y: y + patternY), type: PlatformType(rawValue: type)!)
                                    if let platformNode = platformNode {
                                        foregroundNode.addChild(platformNode)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createPlatformAt(position: CGPoint, type: PlatformType) -> PlatformNode{
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
        sprite.name = "platform"
        node.addChild(sprite)
        
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width, height: sprite.size.height-6))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.CollisionCategoryPlatform
        node.physicsBody?.collisionBitMask = PhysicsCategory.CollisionCategoryPlayer
        node.physicsBody?.allowsRotation = false
        
        return node
    }
    
    func addSpring(){
        springSprite = SKSpriteNode(imageNamed: "spring")
        springSprite.size = CGSize(width: 85, height: 30)
        springSprite.name = "spring"
        springSprite.anchorPoint = CGPoint(x: 0, y: 0)
        springSprite.zPosition = -1
        
        spring.addChild(springSprite)
        spring.position = CGPoint(x:-1, y:125)
        spring.physicsBody = SKPhysicsBody(rectangleOf: springSprite.size)
        spring.physicsBody?.isDynamic = false
        
        addChild(spring)
    }
    
    func showOnboarding(){
        
        onboardingText.text = "Pull back the emoji to start"
        onboardingText.position = CGPoint(x: 220, y: 240)
        onboardingText.fontColor = UIColor(displayP3Red: 235/255, green: 0, blue: 72/255, alpha: 1.0)
        onboardingText.fontSize = CGFloat(24)
        onboardingText.numberOfLines = 2
        onboardingText.preferredMaxLayoutWidth = 200
        onboardingText.horizontalAlignmentMode = .center
        onboardingText.name = "pullBack"
        
        👆.position = CGPoint(x: 120, y: 220)
        👆.size = CGSize(width: 45, height: 45)
        👆.name = "pointer"
        let actionMove = SKAction.move(to: CGPoint(x: 👆.position.x - 30, y: 👆.position.y), duration: TimeInterval(0.8))
        let wait = SKAction.wait(forDuration: 1.0)
        let actionMoveReset = SKAction.move(to: CGPoint(x: 👆.position.x , y: 👆.position.y), duration: TimeInterval(0.0))
        👆.run(SKAction.repeatForever(SKAction.sequence([actionMove, wait, actionMoveReset])), completion: {
            return
            })
        
        bubble.addChild(👆)
        bubble.addChild(onboardingText)
        addChild(bubble)
    }
    
    func nextOnboarding(){
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.8)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.8)
        
        if bubble.childNode(withName: "pullBack") != nil{ //hide and show next
            self.onboardingText.run(fadeOutAction)
            self.👆.run(fadeOutAction)
            self.bubble.run(fadeOutAction, completion: {
                self.onboardingText.text = "Tap to jump"
                self.onboardingText.position = CGPoint(x: 280, y: 250)
                self.onboardingText.name = "tap"
                
                self.👆.removeAllActions()
                self.👆.position = CGPoint(x: 240, y: 210)
                let pulseUp = SKAction.scale(to: 1.2, duration: 1.0)
                let pulseDown = SKAction.scale(to: 0.8, duration: 1.0)
                self.👆.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
                
                self.onboardingText.run(fadeInAction)
                self.👆.run(fadeInAction)
                self.bubble.run(fadeInAction)
                })
        }
        else if bubble.childNode(withName: "tap") != nil{ //remove
            UserDefaults.standard.set(false, forKey: "firstOpen")
            self.onboardingText.run(fadeOutAction)
            self.👆.run(fadeOutAction)
            self.bubble.run(fadeOutAction, completion: {
                self.bubble.removeFromParent()
            })
        }
    }
    
    func addHud(){
        let displaySize: CGRect = UIScreen.main.bounds
        // Score
        let scoreText = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        scoreText.fontSize = 28
        scoreText.zPosition = 10
        scoreText.fontColor = SKColor.black
        scoreText.position = CGPoint(x: displaySize.width-80, y: displaySize.height-40) // self.view.fram.maxY
        scoreText.horizontalAlignmentMode = .right
        scoreText.text = "Score: "
        hudNode.addChild(scoreText)
        
        scoreLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        scoreLabel.fontSize = 28
        scoreLabel.zPosition = 10
        scoreLabel.fontColor = SKColor.black
        print("\(size.width)  \(size.height)")
        print("\(self.frame.maxX)  \(self.frame.maxY)")
        print("\(self.view?.frame.maxX ?? CGFloat(0.0))  \(self.view?.frame.maxY ?? CGFloat(0.0)) ")
        scoreLabel.position = CGPoint(x: scoreText.frame.maxX + 8, y: displaySize.height-40)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.text = "0"
        hudNode.addChild(scoreLabel)
        
        addChild(hudNode)
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
        nextOnboarding()
        
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
                player.physicsBody?.isDynamic = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
//            print(node.name ?? "??")
            if (node.name == "player" || nearPlayer(location: location)) && !didSpring{
                let previousPosition = touch.previousLocation(in: self)
                let translation = CGPoint(x: location.x - previousPosition.x, y: location.y - previousPosition.y)
                slidePlayer(translation: translation, selectedNode: node)
                scrunchSpring(translation: translation)
            }
        }
    }
    
    func nearPlayer(location: CGPoint)-> Bool {
        if (location.x <= player.position.x + 5 || location.x >= player.position.x - 5) &&
            (location.y <= player.position.y + 5 || location.y >= player.position.y - 5){
            return true
        }
        return false
    }
    
    func scrunchSpring(translation: CGPoint) {
        springSprite.size = CGSize(width: max(springSprite.frame.width - abs(translation.x), 45), height: springSprite.frame.height)
    }
    
    func slidePlayer(translation: CGPoint, selectedNode: SKNode) {
        let position = selectedNode.position
        selectedNode.position = CGPoint(x: max(position.x - abs(translation.x), -45), y: position.y )
    }
    
    
    override func update(_ currentTime: CFTimeInterval){
        
        if gameOver {
            return
        }
        
        //award points for travelling farther
        if Int(player.position.x) > maxPlayerX {
            GameState.sharedInstance.score += Int(player.position.x) - maxPlayerX
            maxPlayerX = Int(player.position.x)
            print("\(GameState.sharedInstance.score)")
            scoreLabel.text = "\(GameState.sharedInstance.score)"
        }
        
        if player.position.x > 200.0 {
            foregroundNode.position = CGPoint(x: -(player.position.x - 200.0), y: 0.0)
            spring.position = CGPoint(x: -(player.position.x - 200.0), y: spring.position.y)
        }
        
        // Remove game objects that have passed by
        foregroundNode.enumerateChildNodes(withName: "NODE_PLATFORM", using: { node, stop in
            (node as? PlatformNode)?.checkNodeRemoval(playerX: self.player.position.x)
        })
        if self.player.position.x > spring.position.x + 400.0 {
            spring.removeFromParent()
        }

        //check if the game is over
        //finished level
        if Int(player.position.x) > endLevelX {
            endGame()
        }
        //fell
        if Int(player.position.y) < Int((self.view?.frame.minY)!-10) { // 400 magic number screen size?
            endGame()
        }
    }
    
    func endGame(){
        gameOver = true
        GameState.sharedInstance.saveState()
        let reveal = SKTransition.fade(withDuration: 0.5)//flipHorizontal(withDuration: 0.5)
        let endGameScene = EndGameScene(size: self.size, won: false)
        self.view?.presentScene(endGameScene, transition: reveal)
    }
    
}

struct PhysicsCategory {
    static let CollisionCategoryPlayer    : UInt32 = 0x1 << 0  //0 single 32-bit integer, acting as a bitmask
    static let CollisionCategoryPoint     : UInt32 = 0x1 << 1  //1
    static let CollisionCategoryPlatform  : UInt32 = 0x1 << 2  // 2
    static let CollisionCategoryDevil     : UInt32 = 0x1 << 3  // 2
}

extension Game: SKPhysicsContactDelegate {
    //called whenever there is a collision and contactTestBitMasks are correctly set
    func didBegin(_ contact: SKPhysicsContact) { //contact delegate method implementation
        var updateHUD = true
        
        let other = ((contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node) as! GameObjectNode
        
        updateHUD = other.collisionWithPlayer(player: player)
        
        // Update the HUD if necessary
        if (updateHUD) {
            print(String(GameState.sharedInstance.score))
            scoreLabel.text = String(GameState.sharedInstance.score)
        }
        
    }
    
    
    
}
