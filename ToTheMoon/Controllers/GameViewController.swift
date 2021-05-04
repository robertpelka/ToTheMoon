//
//  GameViewController.swift
//  ToTheMoon
//
//  Created by Robert Pelka on 24/04/2021.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let menuScene = MenuScene(size: view.bounds.size)
            // Set the scale mode to scale to fit the window
            menuScene.scaleMode = .aspectFill
                
            // Present the scene
            view.presentScene(menuScene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
            view.showsPhysics = false
        }
    }

}
