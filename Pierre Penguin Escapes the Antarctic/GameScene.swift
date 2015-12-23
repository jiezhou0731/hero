////
//  GameScene.swift
//  Pierre Penguin Escapes the Antarctic
//

import SpriteKit
import CoreMotion
import GameKit
import iAd

class GameScene: SKScene, SKPhysicsContactDelegate {
    var world = SKNode()
    let player = Player()
    let hud = HUD()
    var screenCenterY = CGFloat()
    let initialPlayerPosition = CGPoint(x: 100,y: 319)
    var playerProgress = CGFloat()
    var nextEncounterSpawnPosition = CGFloat(150)
    var coinsCollected = 0
    var backgrounds:[Background] = []
    let appDefaults = NSUserDefaults.standardUserDefaults()
    

    override func didMoveToView(view: SKView) {
        print ("GameScene start")
        self.view!.showsPhysics = true
        self.view!.multipleTouchEnabled = true
        ObjectPool.gameScene = self
        
        // Set a sky-blue background color:
        self.backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 0.95, alpha: 1.0)
        
        // Add the world node as a child of the scene:
        self.addChild(world)
        
        // Store the vertical center of the screen:
        screenCenterY = self.size.height / 2
        
        

        
        // Spawn the player:
        player.spawn(world, position: initialPlayerPosition)
        
        // Set gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        // Wire up the contact event:
        self.physicsWorld.contactDelegate = self

        // Create the HUD's child nodes:
        hud.createHudNodes()
        // Add the HUD to the scene:
        self.addChild(hud)
        // Position the HUD in front of any other game element
        hud.zPosition = 50
        
        let mapManager = MapManager()
        // Instantiate four Backgrounds to the backgrounds array:
        /*
        
        for _ in 0...1 {
            backgrounds.append(Background())
        }
        // Spawn the new backgrounds:
        backgrounds[0].spawn(world, imageName: "Background-1", zPosition: -5)
        */
        // Play the start sound:
        self.runAction(SKAction.playSoundFileNamed("Sound/StartGame.aif", waitForCompletion: false))
        //StoneManager.initialize()
        
        hud.addPointsForTime = true
    }
    
    let offset = CGFloat(300)
    override func didSimulatePhysics() {
        // Position the backgrounds:
        for background in self.backgrounds {
            background.updatePosition(player.position)
        }
        
        world.position.x = -(player.position.x - (self.size.width / 3))
        world.position.y = -(player.position.y - (self.size.height / 2))
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // Every contact has two bodies, we do not know which body is which.
        // We will find which body is the penguin, then use the other body
        // to determine what type of contact is happening.
        let otherBody:SKPhysicsBody
        // Combine the two penguin physics categories into one mask
        // using the bitwise OR operator |
        let heroMask = PhysicsCategory.player.rawValue
        // Use the bitwise AND operator & to find the penguin.
        // This returns a positive number if bodyA’s category is
        // the same as either the penguin or damagedPenguin:
        if (contact.bodyA.categoryBitMask & heroMask) > 0 {
            // bodyA is the penguin, we want to find out what bodyB is:
            otherBody = contact.bodyB
        }
        else {
            // bodyB is the penguin, we will test against bodyA:
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case PhysicsCategory.geo.rawValue:
            ObjectPool.gameScene?.player.isJumping = false
            break
          
        default:
            print("Contact with no game logic")
        }
    }
    
    // So sad.
    func gameOver() {
        // Show the restart and main menu buttons:
        hud.gameOver()
        // Push their score to the leaderboard:
        updateLeaderboard()
        // Check if they earned the achievement:
        checkForAchievements()
    }
    
    func updateLeaderboard() {
        if GKLocalPlayer.localPlayer().authenticated {
            // Create a new score object, with our new leaderboard:
            let score = GKScore(leaderboardIdentifier: "pierre_penguin_coins")
            // Set the score value to our coin score:
            score.value = Int64(self.coinsCollected)
            // Report the score (must use an array with the score instance):
            GKScore.reportScores([score], withCompletionHandler: {error -> Void in
                // The error handler was used more in previous versions of iOS,
                // it would be unusual to receive an error now:
                if error != nil {
                    print(error)
                }
            })
        }
    }
    
    func checkForAchievements() {
        if GKLocalPlayer.localPlayer().authenticated {
            // Check if they earned 500 coins or more in this game:
            if self.coinsCollected >= 50 {
                let achieve = GKAchievement(identifier: "500_coins")
                // Show a notification that they earned it:
                achieve.showsCompletionBanner = true
                achieve.percentComplete = 100
                // Report the achievement! (must use an array with the achieve instance):
                GKAchievement.reportAchievements([achieve], withCompletionHandler: {error -> Void in
                    // Again, given that the user is authenticated, it is unlikely
                    // to get an error back in current versions of iOS:
                    if error != nil {
                        print(error)
                    }
                })
            }
        }
    }
    
    var lastTouchedNode : SKNode?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (hud.sceneTouchesBegan(touches, withEvent: event)){
            return
        }
        /*
        for touch in (touches) {
            let location = touch.locationInNode(self)
            let nodeTouched = nodeAtPoint(location)
            if let gameSprite = nodeTouched as? GameSprite {
                gameSprite.onTap()
            }
        }
        
        
        */
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (hud.sceneTouchesMoved(touches, withEvent: event)){
            return
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //player.stopFlapping()
        if (hud.sceneTouchesEnded(touches, withEvent: event)){
            return
        }
    }
    
   override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        hud.sceneTouchesCancelled(touches, withEvent: event)
        //player.stopFlapping()
    }
    
    override func update(currentTime: NSTimeInterval) {
        player.update()
        //StoneManager.update(currentTime)
        hud.update(currentTime)
    }
}

/* Physics Categories */
enum PhysicsCategory:UInt32 {
    case player = 1
    case geo = 2
}