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
    
    override func didMove(to view: SKView) {
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        layoutScene()
    }
    
    func layoutScene() {
        backgroundColor = UIColor.darkGray
        
        physicsWorld.contactDelegate = self
        
        let ball = SKShapeNode(circleOfRadius: 20.0)
        ball.fillColor = UIColor.yellow
        ball.position = CGPoint(x: frame.midX, y: frame.minY + ball.frame.height * 4)
        ball.name = "Ball"
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20.0)
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.platformCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        addChild(ball)
        
        let platform = SKShapeNode(rectOf: CGSize(width: 120, height: 20))
        platform.position = CGPoint(x: frame.midX, y: frame.minY + 30)
        platform.fillColor = UIColor.red
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 120, height: 20))
        platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        addChild(platform)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * 30, dy: -9.8)
        }
    }

}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.platformCategory {
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKShapeNode : contact.bodyB.node as? SKShapeNode {
                if let ballVelocity = ball.physicsBody?.velocity.dy {
                    if ballVelocity < 0 {
                        ball.physicsBody?.velocity.dy = 1000
                    }
                }
            }
        }
    }
    
}
