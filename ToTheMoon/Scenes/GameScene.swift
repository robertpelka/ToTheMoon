//
//  GameScene.swift
//  ToTheMoon
//
//  Created by Robert Pelka on 24/04/2021.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    var motionManager: CMMotionManager!
    let ball = SKSpriteNode(imageNamed: "bitcoin")
    var platforms = [SKSpriteNode]()
    var bottom = SKShapeNode()
    let dollar = SKSpriteNode(imageNamed: "dollar")
    let scoreLabel = SKLabelNode(text: "$0")
    var score = 0
    var isGameStarted = false
    
    override func didMove(to view: SKView) {
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        layoutScene()
    }
    
    func layoutScene() {
        addBackground()
        addScoreCounter()
        spawnBall()
        addBottom()
        makePlatforms()
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.frame.size
        background.zPosition = ZPositions.background
        addChild(background)
    }
    
    func addScoreCounter() {
        dollar.texture = SKTexture(imageNamed: "dollar")
        dollar.position = CGPoint(x: view?.safeAreaInsets.top ?? 30, y: frame.height - (view?.safeAreaInsets.top ?? 10) - 20)
        dollar.zPosition = ZPositions.dollar
        addChild(dollar)
        
        scoreLabel.fontSize = 24.0
        scoreLabel.fontName = "HelveticaNeue-Bold"
        scoreLabel.fontColor = UIColor.init(red: 38/255, green: 120/255, blue: 95/255, alpha: 1)
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: dollar.position.x + dollar.frame.width/2 + 10, y: dollar.position.y)
        scoreLabel.zPosition = ZPositions.scoreLabel
        addChild(scoreLabel)
    }
    
    func spawnBall() {
        ball.name = "Ball"
        ball.position = CGPoint(x: frame.midX, y: 20 + ball.size.height/2)
        ball.zPosition = ZPositions.ball
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.platformCategory | PhysicsCategories.strapOfDollarsCategory | PhysicsCategories.dollarWithHoleCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        addChild(ball)
    }
    
    func addBottom() {
        bottom = SKShapeNode(rectOf: CGSize(width: frame.width*2, height: 20))
        bottom.position = CGPoint(x: frame.midX, y: 10)
        bottom.fillColor = UIColor.init(red: 25/255, green: 105/255, blue: 81/255, alpha: 1)
        bottom.strokeColor = bottom.fillColor
        bottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 20))
        bottom.physicsBody?.affectedByGravity = false
        bottom.physicsBody?.isDynamic = false
        bottom.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        addChild(bottom)
    }
    
    func makePlatforms() {
        let spaceBetweenPlatforms = frame.size.height/12
        for i in 0..<Int(frame.size.height/spaceBetweenPlatforms) {
            let x = CGFloat.random(in: 0...frame.size.width)
            let y = CGFloat.random(in: CGFloat(i)*spaceBetweenPlatforms+10...CGFloat(i+1)*spaceBetweenPlatforms-10)
            spawnPlatform(at: CGPoint(x: x, y: y))
        }
    }
    
    func spawnPlatform(at position: CGPoint) {
        var platform = SKSpriteNode()
        if position.x < frame.midX {
            platform = SKSpriteNode(imageNamed: "dollarLeft")
        }
        else {
            platform = SKSpriteNode(imageNamed: "dollarRight")
        }
        platform.position = position
        platform.zPosition = ZPositions.platform
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
        platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platforms.append(platform)
        addChild(platform)
    }
    
    override func update(_ currentTime: TimeInterval) {
        checkPhoneTilt()
        if isGameStarted {
            checkBallPosition()
            checkBallVelocity()
            updatePlatformsPositions()
        }
    }
    
    func checkPhoneTilt() {
        let defaultA = 9.8
        if let accelerometerData = motionManager.accelerometerData {
            var xAcceleration = accelerometerData.acceleration.x * 30
            if xAcceleration > defaultA {
                xAcceleration = defaultA
            }
            else if xAcceleration < -defaultA {
                xAcceleration = -defaultA
            }
            ball.run(SKAction.rotate(toAngle: CGFloat(-xAcceleration/10), duration: 0.1))
            if isGameStarted {
                physicsWorld.gravity = CGVector(dx: xAcceleration, dy: -defaultA)
            }
        }
    }
    
    func checkBallPosition() {
        let ballWidth = ball.size.width
        if ball.position.y+ballWidth < 0 {
            let menuScene = MenuScene.init(size: view!.bounds.size)
            run(SKAction.playSoundFileNamed("gameOver", waitForCompletion: false))
            view?.presentScene(menuScene)
        }
        setScore()
        if ball.position.x-ballWidth >= frame.size.width || ball.position.x+ballWidth <= 0 {
            fixBallPosition()
        }
    }
    
    func setScore() {
        let oldScore = score
        score = (Int(ball.position.y) - Int(ball.size.height/2)) - (Int(bottom.position.y) - Int(bottom.frame.size.height)/2)
        score = score < 0 ? 0 : score
        if score > oldScore {
            dollar.texture = SKTexture(imageNamed: "dollar")
            scoreLabel.fontColor = UIColor.init(red: 38/255, green: 120/255, blue: 95/255, alpha: 1)
            UserDefaults.standard.setValue(score, forKey: "LastScore")
            if score > UserDefaults.standard.integer(forKey: "HighScore") {
                UserDefaults.standard.setValue(score, forKey: "HighScore")
            }
        }
        else {
            dollar.texture = SKTexture(imageNamed: "dollarRed")
            scoreLabel.fontColor = UIColor.init(red: 136/255, green: 24/255, blue: 0/255, alpha: 1)
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "en_US")
        let formattedScore = numberFormatter.string(from: NSNumber(value: score))
        scoreLabel.text = "$" + (formattedScore ?? "0")
    }
    
    func checkBallVelocity() {
        if let ballVelocity = ball.physicsBody?.velocity.dx {
            if ballVelocity > 1000 {
                ball.physicsBody?.velocity.dx = 1000
            }
            else if ballVelocity < -1000 {
                ball.physicsBody?.velocity.dx = -1000
            }
        }
    }
    
    func updatePlatformsPositions() {
        let minimumHeight: CGFloat = frame.size.height/2
        guard let ballVelocity = ball.physicsBody?.velocity.dy else {
            return
        }
        if ball.position.y > minimumHeight && ballVelocity > 0 {
            for platform in platforms {
                platform.position.y -= ballVelocity/50
                if platform.position.y < 0-platform.frame.size.height/2 {
                    update(platform: platform)
                }
            }
            bottom.position.y -= ballVelocity/50
        }
    }
    
    func update(platform: SKSpriteNode) {
        platform.position.x = CGFloat.random(in: 0...frame.size.width)
        
        var direction = "Left"
        if platform.position.x > frame.midX {
            direction = "Right"
        }
        
        platform.removeAllActions()
        platform.alpha = 1.0
        if Int.random(in: 1...5) == 1 {
            platform.texture = SKTexture(imageNamed: "strapOfDollars" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.strapOfDollarsCategory
            if direction == "Left" {
                platform.position.x = 0
                animate(platform: platform, isLeft: true)
            }
            else {
                platform.position.x = frame.size.width
                animate(platform: platform, isLeft: false)
            }
        }
        else if Int.random(in: 1...5) == 1 {
            platform.texture = SKTexture(imageNamed: "dollarWithHole" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.dollarWithHoleCategory
        }
        else {
            platform.texture = SKTexture(imageNamed: "dollar" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        }
        
        platform.position.y = frame.size.height + platform.frame.size.height/2
    }
    
    func updateSizeOf(platform: SKSpriteNode) {
        if let textureSize = platform.texture?.size() {
            platform.size = CGSize(width: textureSize.width, height: textureSize.height)
            platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
            platform.physicsBody?.isDynamic = false
            platform.physicsBody?.affectedByGravity = false
        }
    }
    
    func animate(platform: SKSpriteNode, isLeft: Bool) {
        let distanceX = isLeft ? frame.size.width : -frame.size.width
        platform.run(SKAction.moveBy(x: distanceX, y: 0, duration: 2)) {
            platform.run(SKAction.moveBy(x: -distanceX, y: 0, duration: 2)) {
                self.animate(platform: platform, isLeft: isLeft)
            }
        }
    }
    
    func fixBallPosition() {
        let ballWidth = ball.size.width
        if ball.position.x >= frame.size.width {
            ball.position.x = 0 - ballWidth/2+1
        }
        else {
            ball.position.x = frame.size.width + ballWidth/2-1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameStarted {
            run(SKAction.playSoundFileNamed("jump", waitForCompletion: false))
            ball.physicsBody?.velocity.dy = frame.size.height*1.2 - ball.position.y
            isGameStarted = true
        }
    }

}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if let ballVelocity = ball.physicsBody?.velocity.dy {
            if ballVelocity < 0 {
                if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.platformCategory {
                    run(SKAction.playSoundFileNamed("jump", waitForCompletion: false))
                    ball.physicsBody?.velocity.dy = frame.size.height*1.2 - ball.position.y
                }
                else if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.strapOfDollarsCategory {
                    run(SKAction.playSoundFileNamed("jump", waitForCompletion: false))
                    ball.physicsBody?.velocity.dy = (frame.size.height*1.2 - ball.position.y) * 1.5
                }
                else if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.dollarWithHoleCategory {
                    run(SKAction.playSoundFileNamed("jump", waitForCompletion: false))
                    ball.physicsBody?.velocity.dy = frame.size.height*1.2 - ball.position.y
                    if let platform = (contact.bodyA.node?.name != "Ball") ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                        print("succes")
                        platform.physicsBody?.categoryBitMask = PhysicsCategories.none
                        platform.run(SKAction.fadeOut(withDuration: 0.5))
                    }
                }
            }
        }
    }
}
