import SpriteKit

class Player : SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"player.atlas")
    var status = Dictionary<String, String>()
    
    var walkAnimation = SKAction()
    var deadAnimation = SKAction()
    let playerSpeed = CGFloat(300.0)
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 64, height: 32)) {
        status["isAlive"]="true"
        parentNode.addChild(self)
        createAnimations()
        self.size = size
        self.position = position
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 4)
         self.physicsBody?.mass = 65
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 0.9
        self.physicsBody?.categoryBitMask = PhysicsCategory.player.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.geo.rawValue 
        self.physicsBody?.collisionBitMask = ~(PhysicsCategory.player.rawValue)
      
        
        self.runAction(walkAnimation, withKey: "flyAnimation")

    }
    
    func createAnimations() {
        var walkFrames:[SKTexture] = []
        for index in 1...50 {
            let st = String(format: "walk00%02d.png",index)
            walkFrames.append( textureAtlas.textureNamed(st))
        }
        let walkAction = SKAction.animateWithTextures(walkFrames, timePerFrame: 0.03)
        walkAnimation = SKAction.group([
            SKAction.repeatActionForever(walkAction)
        ])

        
        let deadFrames:[SKTexture] = [
            textureAtlas.textureNamed("dead.png")
        ]
        let deadAction = SKAction.animateWithTextures(deadFrames, timePerFrame: 0.03)
        deadAnimation = SKAction.group([
            SKAction.repeatActionForever(deadAction)
        ])
    }
    
    var isAlive = true
    var isJumping = false
    
    func update() {
        if ( status["isAlive"]=="true" ) {
            if ( ObjectPool.gameScene?.hud.posLButtonIsPushed == true) {
                self.physicsBody?.velocity.dx =  -1 * playerSpeed
            } else if ( ObjectPool.gameScene?.hud.posRButtonIsPushed == true) {
                self.physicsBody?.velocity.dx = playerSpeed
            } else {
                self.physicsBody?.velocity.dx = 0
            }
        } else {
            self.physicsBody?.velocity.dx = 0
        }
        
        if (ObjectPool.gameScene?.hud.pushAButtonIsPushed == true){
            print ("update")
            ObjectPool.gameScene?.hud.pushAButtonIsPushed = false
            if (isJumping == false){
                print ("yes")
                isJumping = true
                self.physicsBody?.applyForce(CGVector(dx: 0, dy: 1300000))
            }
        }
    }
    
    
    func die() {
        isAlive = false
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        self.size = CGSize(width: 64, height: 64)
        self.removeActionForKey("flyAnimation")
        self.runAction(deadAnimation, withKey: "deadAnimation")
        // Alert the GameScene:
        if let gameScene = self.parent?.parent as? GameScene {
            gameScene.gameOver()
        }
    }
    
    func onTap() {}
}