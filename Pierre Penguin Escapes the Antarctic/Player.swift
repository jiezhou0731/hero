//
//  Player.swift
//  Pierre Penguin Escapes the Antarctic
//

import SpriteKit

class Player : SKSpriteNode, GameSprite {
    let protectiveBubble = SKSpriteNode(imageNamed:"protectiveBubble")
    let powerUpDuration = 8.0
    var startTime = NSTimeInterval()
    var timer = NSTimer();
    let protectiveBubbleTimeCount = SKLabelNode(text: "0")
    

    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"pierre.atlas")
    var flyAnimation = SKAction()
    var soarAnimation = SKAction()
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    // Keep track of whether we're flapping our wings or in free-fall:
    var flapping = false
    // 57,000 is a force that feels good to me, you can adjust to taste:
    let maxFlappingForce:CGFloat = 57000
    // We want Pierre to slow down when he flies too high:
    let maxHeight:CGFloat = 600
    var health:Int = 3
    var damaged = false
    var invulnerable = false
    var forwardVelocity:CGFloat = 200
    let powerupSound = SKAction.playSoundFileNamed("Sound/Powerup.aif", waitForCompletion: false)
    let hurtSound = SKAction.playSoundFileNamed("Sound/Hurt.aif", waitForCompletion: false)
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 64, height: 64)) {
        parentNode.addChild(self)
        createAnimations()
        self.size = size
        self.position = position
        self.runAction(soarAnimation, withKey: "soarAnimation")
        
        let physicsTexture = textureAtlas.textureNamed("pierre-flying-3.png")
        self.physicsBody = SKPhysicsBody(
            texture: physicsTexture,
            size: size)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 0.9
        self.physicsBody?.mass = 30
        self.physicsBody?.categoryBitMask = PhysicsCategory.penguin.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy.rawValue |
            PhysicsCategory.ground.rawValue |
            PhysicsCategory.powerup.rawValue |
            PhysicsCategory.coin.rawValue
        self.physicsBody?.collisionBitMask = ~(PhysicsCategory.bullet.rawValue)
        
        // Instantiate an SKEmitterNode with the PierrePath design:
        let dotEmitter = SKEmitterNode(fileNamed: "PierrePath.sks")
        // Place the particle zPosition behind the penguin:
        dotEmitter!.particleZPosition = -1
        // By adding the emitter node to the player, the emitter will move forward
        // with the player and spawn new dots wherever the player moves:
        self.addChild(dotEmitter!)
        // However, we need the particles themselves to be part of the world,
        // so they trail behind the player. Otherwise, they move forward with Pierre.
        // (Note that self.parent refers to the world node)
        dotEmitter!.targetNode = self.parent
        
        // Grant a momentary reprieve from gravity:
        self.physicsBody?.affectedByGravity = false
        // Add some slight upward velocity:
        self.physicsBody?.velocity.dy = 50
        // Create an SKAction to start gravity after a small delay:
        let startGravitySequence = SKAction.sequence([
            SKAction.waitForDuration(0.6),
            SKAction.runBlock {
                self.physicsBody?.affectedByGravity = true
            }])
        self.runAction(startGravitySequence)
    }
    
    func createAnimations() {
        protectiveBubble.position = self.position
        self.addChild(protectiveBubble)
        protectiveBubble.size.height = 1
        protectiveBubble.size.width = 1

        protectiveBubbleTimeCount.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        protectiveBubbleTimeCount.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        protectiveBubbleTimeCount.fontSize = 50
        
        
        let rotateUpAction = SKAction.rotateToAngle(0, duration: 0.475)
        rotateUpAction.timingMode = .EaseOut
        let rotateDownAction = SKAction.rotateToAngle(-1, duration: 0.8)
        rotateDownAction.timingMode = .EaseIn
        
        // Create the flying animation:
        let flyFrames:[SKTexture] = [
            textureAtlas.textureNamed("pierre-flying-1.png"),
            textureAtlas.textureNamed("pierre-flying-2.png"),
            textureAtlas.textureNamed("pierre-flying-3.png"),
            textureAtlas.textureNamed("pierre-flying-4.png"),
            textureAtlas.textureNamed("pierre-flying-3.png"),
            textureAtlas.textureNamed("pierre-flying-2.png")
        ]
        let flyAction = SKAction.animateWithTextures(flyFrames, timePerFrame: 0.03)
        flyAnimation = SKAction.group([
            SKAction.repeatActionForever(flyAction),
            rotateUpAction
        ])
        
        // Create the soaring animation, just one frame for now:
        let soarFrames:[SKTexture] = [textureAtlas.textureNamed("pierre-flying-1.png")]
        let soarAction = SKAction.animateWithTextures(soarFrames, timePerFrame: 1)
        soarAnimation = SKAction.group([
            SKAction.repeatActionForever(soarAction),
            rotateDownAction
        ])
        
        // --- Create the taking damage animation ---
        let damageStart = SKAction.runBlock {
            // Allow the penguin to pass through enemies without colliding:
            self.physicsBody?.categoryBitMask = PhysicsCategory.damagedPenguin.rawValue
            // Use the bitwise NOT operator ~ to remove enemies from the collision test:
            self.physicsBody?.collisionBitMask = ~(PhysicsCategory.enemy.rawValue | PhysicsCategory.bullet.rawValue)
        }
        // Create an opacity fade out and in, slow at first and fast at the end:
        let slowFade = SKAction.sequence([
            SKAction.fadeAlphaTo(0.3, duration: 0.35),
            SKAction.fadeAlphaTo(0.7, duration: 0.35)
            ])
        let fastFade = SKAction.sequence([
            SKAction.fadeAlphaTo(0.3, duration: 0.2),
            SKAction.fadeAlphaTo(0.7, duration: 0.2)
            ])
        let fadeOutAndIn = SKAction.sequence([
            SKAction.repeatAction(slowFade, count: 2),
            SKAction.repeatAction(fastFade, count: 5),
            SKAction.fadeAlphaTo(1, duration: 0.15)
            ])
        // Return the penguin to normal:
        let damageEnd = SKAction.runBlock {
            self.physicsBody?.categoryBitMask = PhysicsCategory.penguin.rawValue
            // Collide with everything again:
            self.physicsBody?.collisionBitMask = ~PhysicsCategory.bullet.rawValue
            self.damaged = false
        }
        // Wire it all together and store it in the damageAnimation property:
        self.damageAnimation = SKAction.sequence([
            damageStart,
            fadeOutAndIn,
            damageEnd
            ])
        
    
        /* --- Create the death animation --- */
        let startDie = SKAction.runBlock {
            // Switch to the death texture:
            self.texture = self.textureAtlas.textureNamed("pierre-dead.png")
            // Suspend the penguin in space:
            self.physicsBody?.affectedByGravity = false
            // Stop any momentum:
            self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            // Make the penguin pass through everything except the ground:
            self.physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue
        }
        
        let endDie = SKAction.runBlock {
            // Turn gravity back on:
            self.physicsBody?.affectedByGravity = true
        }
        
        self.dieAnimation = SKAction.sequence([
            startDie,
            // Scale the penguin bigger:
            SKAction.scaleTo(2.2, duration: 0.5),
            // Use the waitForDuration action to provide a short pause:
            SKAction.waitForDuration(0.5),
            // Rotate the penguin on to his back:
            SKAction.rotateToAngle(3, duration: 1.5),
            SKAction.waitForDuration(0.5),
            endDie
        ])
    }
    
    func update() {
        
        protectiveBubbleTimeCount.position.x = self.position.x
        protectiveBubbleTimeCount.position.y = self.position.y + 50
        
        // If we are flapping, apply a new force to push Pierre higher.
        if (self.flapping) {
            var forceToApply = maxFlappingForce
            
            // Apply less force if Pierre is above position 600
            if (position.y > 500) {
                // We will apply less and less force the higher Pierre goes.
                // These next three lines determine just how much force to mitigate:
                let percentageOfMaxHeight = position.y / maxHeight
                let flappingForceSubtraction = percentageOfMaxHeight * maxFlappingForce
                forceToApply -= flappingForceSubtraction
            }
            // Apply the final force:
            self.physicsBody?.applyForce(CGVector(dx: 0, dy: forceToApply))
        }
        
        // We need to limit Pierre's top speed as he shoots up the y-axis.
        // This prevents him from building up enough momentum to shoot high
        // over our max height. We are bending the physics to improve the gameplay:
        if (self.physicsBody?.velocity.dy > 300) {
            self.physicsBody?.velocity.dy = 300
        }
        
        // Set a constant velocity to the right:
        self.physicsBody?.velocity.dx = self.forwardVelocity
    }
    
    // Begin the flapping animation, and set the flapping property to true:
    func startFlapping() {
        if self.health <= 0 { return }

        self.removeActionForKey("soarAnimation")
        self.runAction(flyAnimation, withKey: "flapAnimation")
        self.flapping = true
    }
    
    // Start the soar animation, and set the flapping property to false:
    func stopFlapping() {
        if self.health <= 0 { return }
        
        self.removeActionForKey("flapAnimation")
        self.runAction(soarAnimation, withKey: "soarAnimation")
        self.flapping = false
    }
    
    func takeDamage() {
        // If currently invulnerable or damaged, return out of the function:
        if self.invulnerable || self.damaged { return }
        // Set the damaged state to true after being hit:
        self.damaged = true
        
        // Remove one from our health pool
        self.health--
        
        if self.health == 0 {
            // If we are out of health, run the die function:
            die()
        }
        else {
            // Run the take damage animation:
            self.runAction(self.damageAnimation)
        }
        
        // Play the hurt sound:
        self.runAction(hurtSound)
    }
    
    func starPower() {
        // Remove any existing star powerup animation:
        // (if the player is already under the power of another star)
        self.removeActionForKey("starPower")
        self.removeActionForKey("protectiveBubble")
        // Grant great forward speed:
        self.forwardVelocity = 700
        // Make the player invulnerable:
        self.invulnerable = true
        // Create a sequence to scale the player larger,
        // wait 8 seconds, then scale back down and turn off
        // invulnerability, returning the player to normal speed:
        let starSequence = SKAction.sequence([
            SKAction.runBlock {
                self.timer = NSTimer()
                if !self.timer.valid {
                    let aSelector : Selector = "updateTimeOfProtectiveBubble"
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector,     userInfo: nil, repeats: true)
                    self.startTime = NSDate.timeIntervalSinceReferenceDate()
                }
                self.updateTimeOfProtectiveBubble()
                if self.protectiveBubbleTimeCount.parent == nil {
                    ObjectPool.gameScene?.world.addChild(self.protectiveBubbleTimeCount)
                }
            },
            SKAction.waitForDuration(self.powerUpDuration-1),
            SKAction.scaleTo(1, duration: 1),
            SKAction.runBlock {
                self.forwardVelocity = 200
                self.invulnerable = false
            }
        ])
        
        let protectiveBubbleSequence = SKAction.sequence([
            SKAction.scaleTo(100, duration: 0.5),
            SKAction.waitForDuration(self.powerUpDuration-1),
            SKAction.scaleTo(1, duration: 1)
        ])
        
        self.protectiveBubble.runAction(protectiveBubbleSequence, withKey:"protectiveBubble")
        // Execute the sequence:
        self.runAction(starSequence, withKey: "starPower")
        // Play the powerup sound:
        self.runAction(powerupSound)
    }
    
    func updateTimeOfProtectiveBubble() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        let elapsedTime: NSTimeInterval = currentTime - self.startTime
        let seconds = UInt(elapsedTime)
        if (seconds < UInt(powerUpDuration)) {
            let remain =  UInt(powerUpDuration)  - seconds
            let strSeconds = String(format: "%d", remain)
            protectiveBubbleTimeCount.text = "\(strSeconds)"
            protectiveBubbleTimeCount.position.x = self.position.x
            protectiveBubbleTimeCount.position.y = self.position.y + 50
        } else {
            if (self.protectiveBubbleTimeCount.parent != nil) {
                self.protectiveBubbleTimeCount.removeFromParent()
            }
            self.timer.invalidate()
        }
    }
    
    func die() {
        // Make sure the player is fully visible:
        self.alpha = 1
        // Remove all animations:
        self.removeAllActions()
        // Run the die animation:
        self.runAction(self.dieAnimation)
        // Prevent any further upward movement:
        self.flapping = false
        // Stop forward movement:
        self.forwardVelocity = 0
        // Alert the GameScene:
        if let gameScene = self.parent?.parent as? GameScene {
            gameScene.gameOver()
        }
    }
    
    func onTap() {}
}