//
//  MenuScene.swift
//  ToTheMoon
//
//  Created by Robert Pelka on 02/05/2021.
//

import SpriteKit

class MenuScene: SKScene {
    
    let logo = SKSpriteNode(imageNamed: "logo")
    
    override func didMove(to view: SKView) {
        addBackground()
        addLogo()
        addLastScore()
        addHighScore()
        addPlayButton()
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.frame.size
        background.zPosition = ZPositions.background
        addChild(background)
    }
    
    func addLogo() {
        let topPosition = frame.height - (view?.safeAreaInsets.top ?? 10)
        logo.position = CGPoint(x: frame.midX, y: topPosition - (logo.size.height/2) - 50)
        logo.zPosition = ZPositions.logo
        addChild(logo)
    }
    
    func addLastScore() {
        let lastScore = UserDefaults.standard.integer(forKey: "LastScore")
        let formattedScore = formatScore(from: lastScore)
        
        let lastScoreLabel = SKLabelNode(text: "Last Score: $" + (formattedScore ?? "0"))
        lastScoreLabel.fontSize = 24.0
        lastScoreLabel.fontName = "HelveticaNeue-Light"
        lastScoreLabel.fontColor = UIColor.init(red: 38/255, green: 120/255, blue: 95/255, alpha: 1)
        lastScoreLabel.position = CGPoint(x: frame.midX, y: logo.position.y - logo.size.height/2 - 20)
        lastScoreLabel.zPosition = ZPositions.scoreLabel
        addChild(lastScoreLabel)
        
    }
    
    func formatScore(from score: Int) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "en_US")
        let formattedScore = numberFormatter.string(from: NSNumber(value: score))
        return formattedScore
    }
    
    func addHighScore() {
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        let formattedScore = formatScore(from: highScore)
        
        let highScoreLabel = SKLabelNode(text: "ATH: $" + (formattedScore ?? "0"))
        highScoreLabel.fontSize = 24.0
        highScoreLabel.fontName = "HelveticaNeue-Bold"
        highScoreLabel.fontColor = UIColor.init(red: 38/255, green: 120/255, blue: 95/255, alpha: 1)
        highScoreLabel.position = CGPoint(x: frame.midX, y: logo.position.y - logo.size.height/2 - 52)
        highScoreLabel.zPosition = ZPositions.scoreLabel
        addChild(highScoreLabel)
    }
    
    func addPlayButton() {
        let playButton = SKSpriteNode(imageNamed: "playButton")
        playButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        playButton.zPosition = ZPositions.logo
        addChild(playButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: view!.bounds.size)
        view?.presentScene(gameScene)
    }
    
}
