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
    
    override func didMove(to view: SKView) {
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()

        layoutScene()
    }
    
    func layoutScene() {
        physicsWorld.contactDelegate = self
        
        addBackground()
        spawnBall()
        addBottom()
        makePlatforms()
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.frame.size
        background.zPosition = -1
        addChild(background)
    }
    
    func spawnBall() {
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.zPosition = 2
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.platformCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        addChild(ball)
    }
    
    func addBottom() {
        bottom = SKShapeNode(rectOf: CGSize(width: frame.width, height: 20))
        bottom.position = CGPoint(x: frame.midX, y: 10)
        bottom.fillColor = UIColor.init(red: 19/255, green: 69/255, blue: 51/255, alpha: 1)
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
        platform.zPosition = 1
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
        platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platforms.append(platform)
        addChild(platform)
    }
    
    override func update(_ currentTime: TimeInterval) {
        checkPhoneTilt()
        checkBallPosition()
        checkBallVelocity()
        updatePlatformsPositions()
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
            physicsWorld.gravity = CGVector(dx: xAcceleration, dy: -defaultA)
        }
    }
    
    func checkBallPosition() {
        let ballWidth = ball.size.width
        if ball.position.y+ballWidth < 0 {
            ball.removeFromParent()
        }
        if ball.position.x-ballWidth >= frame.size.width || ball.position.x+ballWidth <= 0 {
            fixBallPosition()
        }
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
                    platform.position.y = frame.size.height + platform.frame.size.height/2
                    platform.position.x = CGFloat.random(in: 0...frame.size.width)
                    if platform.position.x < frame.midX {
                        platform.texture = SKTexture(imageNamed: "dollarLeft")
                    }
                    else {
                        platform.texture = SKTexture(imageNamed: "dollarRight")
                    }
                }
            }
            bottom.position.y -= ballVelocity/50
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
        spawnBall()
    }

}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.platformCategory {
            if let ballVelocity = ball.physicsBody?.velocity.dy {
                if ballVelocity < 0 {
                    ball.physicsBody?.velocity.dy = frame.size.height*1.2 - ball.position.y
                }
            }
        }
    }
    
}
