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
    var inAir = false
    var endLevelX: Int
    var maxPlayerX: Int
    let levelPlist: String
    let levelData: NSDictionary
    
    let displaySize: CGRect = UIScreen.main.bounds
    override init(size: CGSize) {
        // Load the level
        levelPlist = Bundle.main.path(forResource: "Level01", ofType: "plist")!
        levelData = NSDictionary(contentsOfFile: levelPlist)!
        
        endLevelX = levelData["EndX"] as! Int
        maxPlayerX = 85 //needs to be at least 85
        
        GameState.sharedInstance.score = 0 //reset the game each time
        gameOver = false
        
        super.init(size: size)
        backgroundColor = UIColor.white
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.0)
        physicsWorld.contactDelegate = self
        
        addSpring()
        foregroundNode.addChild(createPlatformAt(position: CGPoint(x:85, y:110), type: PlatformType.PLATFORM_GREEN))
        addPlatforms()
        addPointNodes()
        addPlayer()
        addDevils()
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
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = true //TODO doesnt work
        player.physicsBody?.restitution = 0.2
        player.physicsBody?.friction = 0.0
        player.physicsBody?.angularDamping = 0.0
        player.physicsBody?.linearDamping = 0.0
        
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.CollisionCategoryPlayer
        player.physicsBody?.collisionBitMask = PhysicsCategory.CollisionCategoryPlatform
        player.physicsBody?.contactTestBitMask =  PhysicsCategory.CollisionCategoryPoint | PhysicsCategory.CollisionCategoryDevil
    
        foregroundNode.addChild(player)
        
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
                        if let type = platformPosition?["type"] as? Int{
                            // Look up the pattern
                            if let platformPattern = platformPatterns[pattern] as? NSArray{
                                for platformPoint: [AnyHashable : Any]? in platformPattern as! [[AnyHashable : Any]?] {
                                    let x = CGFloat(((platformPoint?["x"] as? NSNumber)?.floatValue)!)
                                    let y = CGFloat(((platformPoint?["y"] as? NSNumber)?.floatValue)!)
                                    
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
        node.name = "platform"
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
        node.physicsBody?.contactTestBitMask =  PhysicsCategory.CollisionCategoryPlayer
        node.physicsBody?.allowsRotation = false
        
        return node
    }
    
    // MARK: ⭐️&💎
    
    func addPointNodes(){
        if let points = levelData["Stars"] as? [AnyHashable : Any] {
            if let pointPatterns = points["Patterns"] as? [AnyHashable : Any]{
                if let positions = points["Positions"] as? [Any]{
                    
                    for pointPosition: [AnyHashable : Any]? in positions as? [[AnyHashable : Any]?] ?? [] {
                        let patternX =  CGFloat(((pointPosition?["x"] as? NSNumber)?.floatValue)!)
                        let patternY =  CGFloat(((pointPosition?["y"] as? NSNumber)?.floatValue)!)
                        let pattern = pointPosition?["pattern"] as! String
                        
                        // Look up the pattern
                        if let pointPattern = pointPatterns[pattern] as? NSArray{
                            for point: [AnyHashable : Any]? in pointPattern as! [[AnyHashable : Any]?] {
                                let x = CGFloat(((point?["x"] as? NSNumber)?.floatValue)!)
                                let y = CGFloat(((point?["y"] as? NSNumber)?.floatValue)!)
                                if let type = point?["type"] as? Int{
                                    let pointNode: PointNode? = createPointAt(position: CGPoint(x: x + patternX, y: y + patternY), type: PointNodeType(rawValue: type)!)
                                    if let pointNode = pointNode {
                                        foregroundNode.addChild(pointNode)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createPointAt(position: CGPoint, type: PointNodeType) -> PointNode{
        let node = PointNode()
        node.position = position
//        node.name = "point"
        node.pointType = type
        let path: CGPath!
        let sprite : SKSpriteNode
        if type == PointNodeType.STAR {
            sprite = SKSpriteNode(imageNamed: "star")
            node.name = "star"
            path = makeStarPath()
        }
        else {// type == PointNodeType.DIAMOND
            sprite = SKSpriteNode(imageNamed: "diamond")
            node.name = "diamond"
            path = makeDiamondPath()
        }
        
        sprite.size = CGSize(width: 35, height: 35)
        node.addChild(sprite)

        node.physicsBody = SKPhysicsBody(polygonFrom: path)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.CollisionCategoryPoint
        node.physicsBody?.collisionBitMask = 0//PhysicsCategory.CollisionCategoryPoint
        node.physicsBody?.contactTestBitMask = PhysicsCategory.CollisionCategoryPlayer
        
        return node
    }
    
    func makeDiamondPath() -> CGPath{
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: -12))
        path.addLine(to: CGPoint(x: -13, y: 6))
        path.addLine(to: CGPoint(x: -13, y: 8))
        path.addLine(to: CGPoint(x: -4, y: 14))
        path.addLine(to: CGPoint(x: 6, y: 14))
        path.addLine(to: CGPoint(x: 15, y: 8))
        path.addLine(to: CGPoint(x: 15, y: 6))
        path.close()
        return path.cgPath
    }
    
    func makeStarPath() -> CGPath{
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: -10))
        path.addLine(to: CGPoint(x: -12, y: -16))
        path.addLine(to: CGPoint(x: -7, y: -4))
        path.addLine(to: CGPoint(x: -16, y: 4))
        path.addLine(to: CGPoint(x: -5, y: 4))
        path.addLine(to: CGPoint(x: 0, y: 16))
        path.addLine(to: CGPoint(x: 5, y: 4))
        path.addLine(to: CGPoint(x: 16, y: 4))
        path.addLine(to: CGPoint(x: 7, y: -4))
        path.addLine(to: CGPoint(x: 12, y: -16))
        path.close()
        return path.cgPath
    }
    
    
    // MARK: 😈
    
    func addDevils(){
        if let devils = levelData["Devils"] as? [AnyHashable : Any] {
            if let devilPatterns = devils["Patterns"] as? [AnyHashable : Any]{
                if let positions = devils["Positions"] as? [Any]{
                    
                    for devilPosition: [AnyHashable : Any]? in positions as? [[AnyHashable : Any]?] ?? [] {
                        let patternX =  CGFloat(((devilPosition?["x"] as? NSNumber)?.floatValue)!)
                        let patternY =  CGFloat(((devilPosition?["y"] as? NSNumber)?.floatValue)!)
                        let pattern = devilPosition?["pattern"] as! String
                        
                        // Look up the pattern
                        if let devilPattern = devilPatterns[pattern] as? NSArray{
                            for devil: [AnyHashable : Any]? in devilPattern as! [[AnyHashable : Any]?] {
                                let x = CGFloat(((devil?["x"] as? NSNumber)?.floatValue)!)
                                let y = CGFloat(((devil?["y"] as? NSNumber)?.floatValue)!)
                                let devilNode: DevilNode? = createDevilAt(position: CGPoint(x: x + patternX, y: y + patternY))
                                if let devilNode = devilNode {
                                    foregroundNode.addChild(devilNode)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createDevilAt(position: CGPoint) -> DevilNode{
        let node = DevilNode()
        node.position = position
        node.name = "devil"
        let sprite = SKSpriteNode(imageNamed: "devil")
        sprite.size = CGSize(width: 35, height: 35)
        
        node.addChild(sprite)
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.CollisionCategoryDevil
        node.physicsBody?.collisionBitMask = PhysicsCategory.CollisionCategoryPlayer
        node.physicsBody?.contactTestBitMask = PhysicsCategory.CollisionCategoryPlayer
        
        return node
    }

    
    func addSpring(){
        springSprite = SKSpriteNode(imageNamed: "spring")
        springSprite.size = CGSize(width: 85, height: 30)
        springSprite.name = "spring"
        springSprite.anchorPoint = CGPoint(x: 0, y: 0)
        springSprite.zPosition = -1
        
        spring.addChild(springSprite)
        spring.position = CGPoint(x:-10, y:125)
        spring.physicsBody = SKPhysicsBody(rectangleOf: springSprite.size)
        spring.physicsBody?.isDynamic = false
        
        addChild(spring)
    }
    
    func showOnboarding(){
        onboardingText.text = "Pull back the emoji to start"
        onboardingText.position = CGPoint(x: 150, y: displaySize.height - 120)
        onboardingText.fontColor = UIColor(displayP3Red: 235/255, green: 0, blue: 72/255, alpha: 1.0)
        onboardingText.fontSize = CGFloat(24)
        onboardingText.zPosition = 5
        onboardingText.numberOfLines = 2
        onboardingText.preferredMaxLayoutWidth = 200
        onboardingText.horizontalAlignmentMode = .center
        onboardingText.name = "pullBack"
        
        👆.position = CGPoint(x: player.frame.maxX, y: player.frame.minY - player.frame.size.height - 55)
        👆.size = CGSize(width: 45, height: 45)
        👆.name = "pointer"
        👆.zPosition = 5
        let actionMove = SKAction.move(to: CGPoint(x: 👆.position.x - 30, y: 👆.position.y), duration: TimeInterval(0.8))
        let wait = SKAction.wait(forDuration: 1.0)
        let actionMoveReset = SKAction.move(to: CGPoint(x: 👆.position.x , y: 👆.position.y), duration: TimeInterval(0.0))
        👆.run(SKAction.repeatForever(SKAction.sequence([actionMove, wait, actionMoveReset])), completion: {
            return
            })
        
        let haze = SKShapeNode(rect: CGRect(x: 0,
                                            y: 0,
                                            width: displaySize.width,
                                            height: displaySize.height))
        haze.glowWidth = 1.0
        haze.fillColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.6)
        haze.zPosition = 4
        
        bubble.addChild(haze)
        bubble.addChild(👆)
        bubble.addChild(onboardingText)
        addChild(bubble)
    }
    
    func nextOnboarding(){
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.6)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.6)
        
        if bubble.childNode(withName: "pullBack") != nil{ //hide and show next
            self.onboardingText.run(fadeOutAction)
            self.👆.run(fadeOutAction)
            self.bubble.run(fadeOutAction, completion: {
                self.onboardingText.text = "Tap to jump"
                self.onboardingText.position = CGPoint(x: 380, y: 250)
                self.onboardingText.name = "tap"
                
                self.👆.removeAllActions()
                self.👆.position = CGPoint(x: 380, y: 210)
                let pulseUp = SKAction.scale(to: 1.2, duration: 1.0)
                let pulseDown = SKAction.scale(to: 0.8, duration: 1.0)
                self.👆.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
                
                self.onboardingText.run(fadeInAction)
                self.👆.run(fadeInAction)
                self.bubble.run(fadeInAction)
                })
        }
        else if bubble.childNode(withName: "tap") != nil{ //remove
            GameState.sharedInstance.saveState()
            firstGame = false
            self.onboardingText.run(fadeOutAction)
            self.👆.run(fadeOutAction)
            self.bubble.run(fadeOutAction, completion: {
                self.bubble.removeFromParent()
            })
        }
    }
    
    func addHud(){
        // Score
        let scoreText = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        scoreText.fontSize = 28
        scoreText.zPosition = 10
        scoreText.fontColor = SKColor.black
        scoreText.position = CGPoint(x: displaySize.width-80, y: displaySize.height-40)
        scoreText.horizontalAlignmentMode = .right
        scoreText.text = "Score: "
        hudNode.addChild(scoreText)
        
        scoreLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        scoreLabel.fontSize = 28
        scoreLabel.zPosition = 10
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: scoreText.frame.maxX + 8, y: displaySize.height-40)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.text = "0"
        hudNode.addChild(scoreLabel)
        
        //help
        let helpLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        helpLabel.fontSize = 28
        helpLabel.fontColor = SKColor.black
        helpLabel.position = CGPoint(x: displaySize.minX + 22, y: displaySize.height-40)
        helpLabel.horizontalAlignmentMode = .left
        helpLabel.text = "?"
        helpLabel.name = "?"
        hudNode.addChild(helpLabel)
        
        let circ = SKShapeNode(circleOfRadius: helpLabel.frame.width+2)
        circ.strokeColor = UIColor.black
        circ.lineWidth = 2.6
        circ.position = CGPoint(x: helpLabel.frame.midX , y: helpLabel.frame.midY)
        circ.name = "?"
        circ.fillColor = UIColor.white

        hudNode.addChild(circ)
        
        addChild(hudNode)
    }
    
    // MARK: Handle Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !inAir && didSpring{ //tap to jump
            player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 45.0))
            inAir = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        if firstGame{
            nextOnboarding()
        }
        else{
            for touch in touches {
                let location = touch.location(in: self)
                let node : SKNode = self.atPoint(location)
                if node.name == "player" || node.name == "spring" {
                    let expand = SKAction.resize(toWidth: 89.0, duration: TimeInterval(0.3))
                    let retract = SKAction.resize(toWidth: 85.0, duration: TimeInterval(0.3))
                    springSprite.run(SKAction.sequence([expand, retract]))
                    player.physicsBody?.isDynamic = true
                    if !didSpring{
                        player.physicsBody?.applyImpulse(CGVector(dx: 26.0, dy: 0.0)) //TODO force based on pull back distance
                        didSpring = true
                        rotateForever()
                    }
                }
                if node.name == "?" {
                    firstGame = true
                    showOnboarding()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !firstGame{
            for touch in touches {
                let location = touch.location(in: self)
                let node : SKNode = self.atPoint(location)
                if (node.name == "player" || nearPlayer(location: location)) && !didSpring && node.name != "platform" {
                    let previousPosition = touch.previousLocation(in: self)
                    let translation = CGPoint(x: location.x - previousPosition.x, y: location.y - previousPosition.y)
                    slidePlayer(translation: translation)
                    scrunchSpring(translation: translation)
                }
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
    
    func slidePlayer(translation: CGPoint) {
        let position = player.position
        player.position = CGPoint(x: max(position.x - abs(translation.x), -45), y: position.y )
    }
    
    func rotateForever(){
        let oneRevolution = SKAction.rotate(byAngle: -.pi * 2, duration: 1.0) //TODO adjust rotation speed based on player speed
        player.run(SKAction.repeatForever(oneRevolution))
    }
    
    override func update(_ currentTime: CFTimeInterval){
        if gameOver {
            return
        }
        
        //award points for travelling farther
        if Int(player.position.x) > maxPlayerX {
            GameState.sharedInstance.score += Int((Int(player.position.x) - maxPlayerX)/5)
            maxPlayerX = Int(player.position.x)
            scoreLabel.text = "\(GameState.sharedInstance.score)"
        }
        
        // Calculate player y offset and hide nodes
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
        
        //ensure player never slows down
        if player.physicsBody!.velocity.dx < 330 && didSpring {
            player.physicsBody!.velocity = CGVector(dx: 330, dy: player.physicsBody!.velocity.dy)
        }

        //check if the game is over
        //reached end of level
        if Int(player.position.x) >= endLevelX {
            gameOver = true
            //stop emoji from moving
            player.physicsBody?.isDynamic = false
            player.removeAllActions()
            fireworks() //celebrate winning
        }
        //fell
        if Int(player.position.y) <= Int((self.view?.frame.minY)!) + 22 {
            killEmoji()
        }
    }
    
    func endGame(){
        GameState.sharedInstance.saveState()
        let wait = SKAction.wait(forDuration: 0.3)
        let reveal = SKTransition.fade(withDuration: 0.8)//flipHorizontal(withDuration: 0.5)
        let endGameScene = EndGameScene(size: self.size, won: false)
        run(wait, completion: {
            self.view?.presentScene(endGameScene, transition: reveal)
        })
    }
    
    func killEmoji(){
        gameOver = true
        player.removeAllChildren()
        player.removeAllActions()
        let sprite = SKSpriteNode(imageNamed: "dizzyEmoji")
        sprite.size = CGSize(width: 45, height: 45)
        sprite.name = "player"
        player.physicsBody?.isDynamic = false
        player.addChild(sprite)
        
        endGame()
//        let angel = SKNode() TODO
//        let angelSprite = SKSpriteNode(imageNamed: <#T##String#>)
    }
    
    func fireworks(){
        run(SKAction.wait(forDuration: 0.2), completion: {
            for i in 1...5 {
                if let emitter = SKEmitterNode(fileNamed: "Firework") {
                    emitter.position = CGPoint(x: CGFloat(i*110), y: self.displaySize.maxY/CGFloat(i))
                    emitter.zPosition = 100
                    self.addChild(emitter)
                }
            }
            self.run(SKAction.wait(forDuration: 0.5), completion: {
                for i in 1...5 {
                    if let emitter = SKEmitterNode(fileNamed: "Firework") {
                        emitter.position = CGPoint(x: self.displaySize.maxX/CGFloat(i), y: self.displaySize.maxY/CGFloat(i))
                        emitter.zPosition = 100
                        self.addChild(emitter)
                    }
                }
                self.run(SKAction.wait(forDuration: 0.5), completion:{
                    if let emitter = SKEmitterNode(fileNamed: "Firework") {
                        emitter.position = CGPoint(x: self.displaySize.midX-CGFloat(200), y: self.displaySize.midY)
                        emitter.zPosition = 100
                        if let emitter2 = SKEmitterNode(fileNamed: "Firework") {
                            emitter2.position = CGPoint(x: self.displaySize.midX+CGFloat(200), y: self.displaySize.midY)
                            emitter2.zPosition = 100
                            if let emitter3 = SKEmitterNode(fileNamed: "Firework") {
                                emitter3.position = CGPoint(x: self.displaySize.midX, y: self.displaySize.midY)
                                emitter3.zPosition = 100
                                self.addChild(emitter)
                                self.addChild(emitter2)
                                self.addChild(emitter3)
                            }
                        }
                    }
                    self.run(SKAction.wait(forDuration: 0.55), completion: {
                        self.endGame()
                    })
                })
            })
        })
    }
    
}

struct PhysicsCategory {
    static let CollisionCategoryPlayer    : UInt32 = 0x1 << 0  //00000001
    static let CollisionCategoryPoint     : UInt32 = 0x1 << 1  //00000010
    static let CollisionCategoryPlatform  : UInt32 = 0x1 << 2  //00000100
    static let CollisionCategoryDevil     : UInt32 = 0x1 << 3  //00001000
}

extension Game: SKPhysicsContactDelegate {
    //called whenever there is a collision and contactTestBitMasks are correctly set
    func didBegin(_ contact: SKPhysicsContact) { //contact delegate method implementation
        var updateHUD = true
        
        if let other = ((contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node) as? GameObjectNode {
            if other.name == "platform"{
                inAir = false
            }
            else if other.name == "diamond"{
                GameState.sharedInstance.score += 100
            }
            else if other.name == "star"{
                GameState.sharedInstance.score += 10
            }
            else if other.name == "devil"{
                killEmoji()
            }
            updateHUD = other.collisionWithPlayer(player: player)
        }
        
        // Update the HUD if necessary
        if (updateHUD) {
            scoreLabel.text = String(GameState.sharedInstance.score)
        }
        
    }
    
    
    
}
