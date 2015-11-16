//
//  GameScene.swift
//  Pierre Penguin Escapes the Antarctic
//

import SpriteKit
import CoreMotion
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let world = SKNode()
    let player = Player()
    let ground = Ground()
    let hud = HUD()
    var screenCenterY = CGFloat()
    let initialPlayerPosition = CGPoint(x: 150, y: 250)
    var playerProgress = CGFloat()
    let encounterManager = EncounterManager()
    var nextEncounterSpawnPosition = CGFloat(150)
    let powerUpStar = Star()
    var coinsCollected = 0
    var backgrounds:[Background] = []
    let gun = Gun()
    
    override func didMoveToView(view: SKView) {
        self.view!.multipleTouchEnabled = true
        ObjectPool.gameScene = self
        
        // Set a sky-blue background color:
        self.backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 0.95, alpha: 1.0)
        
        // Add the world node as a child of the scene:
        self.addChild(world)
        
        // Store the vertical center of the screen:
        screenCenterY = self.size.height / 2
        
        // Add the encounters as children of the world:
        encounterManager.addEncountersToWorld(self.world)
        
        // Spawn the ground:
        let groundPosition = CGPoint(x: -self.size.width, y: 30)
        let groundSize = CGSize(width: self.size.width * 3, height: 0)
        ground.spawn(world, position: groundPosition, size: groundSize)
        
        // Spawn the star, out of the way for now
        powerUpStar.spawn(world, position: CGPoint(x: -2000, y: -2000))
        
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
        
        // Instantiate four Backgrounds to the backgrounds array:
        
        
        for i in 0...3 {
            backgrounds.append(Background())
        }
        // Spawn the new backgrounds:
        backgrounds[0].spawn(world, imageName: "Background-1", zPosition: -5, movementMultiplier: 0.75)
        backgrounds[1].spawn(world, imageName: "Background-2", zPosition: -10, movementMultiplier: 0.5)
        backgrounds[2].spawn(world, imageName: "Background-3", zPosition: -15, movementMultiplier: 0.2)
        backgrounds[3].spawn(world, imageName: "Background-4", zPosition: -20, movementMultiplier: 0.1)

        // Play the start sound:
        self.runAction(SKAction.playSoundFileNamed("Sound/StartGame.aif", waitForCompletion: false))
        
    }
    
    override func didSimulatePhysics() {
        var worldYPos:CGFloat = 0
        
        // Zoom the world out slightly as the penguin flies higher
        if (player.position.y > screenCenterY) {
            let percentOfMaxHeight = (player.position.y - screenCenterY) / (player.maxHeight - screenCenterY)
            let scaleSubtraction = (percentOfMaxHeight > 1 ? 1 : percentOfMaxHeight) * 0.3
            let newScale = 1 - scaleSubtraction
            world.yScale = newScale
            world.xScale = newScale
            
            worldYPos = -(player.position.y * world.yScale - (self.size.height / 2))
        }
        
        let worldXPos = -(player.position.x * world.xScale - (self.size.width / 3))
        
        // Move the world for our adjustment:
        world.position = CGPoint(x: worldXPos, y: worldYPos)
        
        // Keep track of how far the player has flown
        playerProgress = player.position.x - initialPlayerPosition.x
        
        // Check to see if the ground should jump forward:
        ground.checkForReposition(playerProgress)
        
        // Check to see if we should set a new encounter:
        if player.position.x > nextEncounterSpawnPosition {
            encounterManager.placeNextEncounter(nextEncounterSpawnPosition)
            nextEncounterSpawnPosition += 1400
            
            // Each encounter has a 1 in 10 chance of spawning a star power-up:
            var starRoll = Int(arc4random_uniform(10))
            starRoll = 0
            if starRoll == 0 {
                if abs(player.position.x - powerUpStar.position.x) > 1200 {
                    // Only move the star if it's already far away from the player.
                    let randomYPos = CGFloat(arc4random_uniform(400))
                    powerUpStar.position = CGPoint(x: nextEncounterSpawnPosition, y: randomYPos)
                    powerUpStar.physicsBody?.angularVelocity = 0
                    powerUpStar.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
            }
        }
        
        // Position the backgrounds:
        for background in self.backgrounds {
            background.updatePosition(playerProgress)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // Every contact has two bodies, we do not know which body is which.
        // We will find which body is the penguin, then use the other body
        // to determine what type of contact is happening.
        let otherBody:SKPhysicsBody
        // Combine the two penguin physics categories into one mask
        // using the bitwise OR operator |
        let penguinMask = PhysicsCategory.penguin.rawValue | PhysicsCategory.damagedPenguin.rawValue
        // Use the bitwise AND operator & to find the penguin.
        // This returns a positive number if bodyA’s category is
        // the same as either the penguin or damagedPenguin:
        if (contact.bodyA.categoryBitMask & penguinMask) > 0 {
            // bodyA is the penguin, we want to find out what bodyB is:
            otherBody = contact.bodyB
        }
        else {
            // bodyB is the penguin, we will test against bodyA:
            otherBody = contact.bodyA
        }
        // Find the contact type:
        if (otherBody.categoryBitMask & PhysicsCategory.bullet.rawValue)>0 {
            return;
        }
        
        switch otherBody.categoryBitMask {
        case PhysicsCategory.ground.rawValue:
            player.takeDamage()
            hud.setHealthDisplay(player.health)
        case PhysicsCategory.enemy.rawValue:
            player.takeDamage()
            hud.setHealthDisplay(player.health)
        case PhysicsCategory.coin.rawValue:
            // Try to cast the otherBody's node as a Coin:
            if let coin = otherBody.node as? Coin {
                coin.collect()
                self.coinsCollected += coin.value
                hud.setCoinCountDisplay(self.coinsCollected)
            }
        case PhysicsCategory.powerup.rawValue:
            player.starPower()
        default:
            print("Contact with no game logic")
        }
    }
    
    // So sad.
    func gameOver() {
        // Show the restart and main menu buttons:
        hud.showButtons()
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (hud.sceneTouchesBegan(touches, withEvent: event)){
            return
        }
       
        for touch in (touches) {
            let location = touch.locationInNode(self)
            let nodeTouched = nodeAtPoint(location)
            
            if let gameSprite = nodeTouched as? GameSprite {
                gameSprite.onTap()
            }
        }
        
        if (gun.sceneTouchesBegan(touches, withEvent: event)){
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
    }
}

/* Physics Categories */
enum PhysicsCategory:UInt32 {
    case penguin = 1
    case damagedPenguin = 2
    case ground = 4
    case enemy = 8
    case coin = 16
    case powerup = 32
    case bullet = 64
}