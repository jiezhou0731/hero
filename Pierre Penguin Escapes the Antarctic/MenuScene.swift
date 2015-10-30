//
//  MenuScene.swift
//  Pierre Penguin Escapes the Antarctic
//

import SpriteKit
import GameKit

class MenuScene: SKScene, GKGameCenterControllerDelegate {
    // Grab the HUD texture atlas:
    let textureAtlas:SKTextureAtlas =
    SKTextureAtlas(named:"hud.atlas")
    // Instantiate a sprite node for the start button (we'll use
    // this in a moment):
    let startButton = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        print(self.size)
        // Position nodes from the center of the scene:
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // Set a sky-blue background color:
        self.backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 0.95, alpha: 1.0)
        // Add the background image:
        let backgroundImage = SKSpriteNode(imageNamed: "Background-menu")
        backgroundImage.size = CGSize(width: 1024, height: 768)
        self.addChild(backgroundImage)

        // Draw the name of the game:
        let logoText = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        logoText.text = "Pierre Penguin"
        logoText.position = CGPoint(x: 0, y: 100)
        logoText.fontSize = 60
        self.addChild(logoText)
        // Add another line below:
        let logoTextBottom = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        logoTextBottom.text = "Escapes the Antarctic"
        logoTextBottom.position = CGPoint(x: 0, y: 50)
        logoTextBottom.fontSize = 40
        self.addChild(logoTextBottom)
        
        // Build the start game button:
        startButton.texture = textureAtlas.textureNamed("button.png")
        startButton.size = CGSize(width: 295, height: 76)
        startButton.name = "StartBtn"
        startButton.position = CGPoint(x: 0, y: -20)
        self.addChild(startButton)
        
        // Add text to the start button:
        let startText = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        startText.text = "START GAME"
        startText.verticalAlignmentMode = .Center
        startText.position = CGPoint(x: 0, y: 2)
        startText.fontSize = 40
        startText.name = "StartBtn"
        startButton.addChild(startText)
        
        // Pulse the start button in and out gently:
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlphaTo(0.7, duration: 0.9),
            SKAction.fadeAlphaTo(1, duration: 0.9),
            ])
        startButton.runAction(SKAction.repeatActionForever(pulseAction))
        
        // If they're logged in, create the leaderboard button
        // (This will only apply to players returning to the menu after a game)
        if GKLocalPlayer.localPlayer().authenticated {
            createLeaderboardButton()
        }
    }
    
    func createLeaderboardButton() {
        // Add some text to open the leaderboard
        let leaderboardText = SKLabelNode(fontNamed: "AvenirNext")
        leaderboardText.text = "Leaderboard"
        leaderboardText.name = "LeaderboardBtn"
        leaderboardText.position = CGPoint(x: 0, y: -100)
        leaderboardText.fontSize = 20
        self.addChild(leaderboardText)
    }
    
    func showLeaderboard() {
        // Create a new instance of a game center view controller:
        let gameCenter = GKGameCenterViewController()
        // Set this scene as the delegate (helps enable the done button in the game center)
        gameCenter.gameCenterDelegate = self
        // Show the leaderboards when the game center opens:
        gameCenter.viewState = GKGameCenterViewControllerState.Leaderboards
        // Find the current view controller so we can show the leaderboard controller:
        if let gameViewController = self.view?.window?.rootViewController {
            // Display the new game center view controller to show the leader board:
            gameViewController.showViewController(gameCenter, sender: self)
            gameViewController.navigationController?
                .pushViewController(gameCenter, animated: true)
        }
    }
    
    // The class requires this function to adhere to the GKGameCenterControllerDelegate protocol
    // It hides the game center view controller when the user taps 'done'
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            let nodeTouched = nodeAtPoint(location)
            
            if nodeTouched.name == "StartBtn" {
                self.view?.presentScene(GameScene(size: self.size))
            }
            else if nodeTouched.name == "LeaderboardBtn" {
                showLeaderboard()
            }
        }
    }
}
