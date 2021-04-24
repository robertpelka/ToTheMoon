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
        
        let ball = SKShapeNode(circleOfRadius: 20.0)
        ball.fillColor = UIColor.yellow
        ball.position = CGPoint(x: frame.midX, y: frame.minY + ball.frame.height * 3)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20.0)
        ball.physicsBody?.affectedByGravity = true
        addChild(ball)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = motionManager.accelerometerData {
            print(accelerometerData.acceleration.x)
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * 30, dy: 0)
        }
    }

}
