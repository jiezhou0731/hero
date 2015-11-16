//
//  MadFly.swift
//  Pierre Penguin Escapes the Antarctic
//

import SpriteKit

class Bullet: SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"bullet.atlas")
    var flyAnimation = SKAction()
    let bulletSpeed = CGFloat(1000.0)
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 60, height: 60)) {
        parentNode.addChild(self)
        createAnimations()
        self.size = size
        self.position = position
        self.runAction(flyAnimation)
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.bullet.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.bullet.rawValue
        self.physicsBody?.friction = 0.0;
        self.physicsBody?.mass = 0.0
        
        self.physicsBody?.applyForce(CGVector(dx: 30000.0,dy: 0.0))
    }
    
    func createAnimations() {
        let flyFrames:[SKTexture] = [
            textureAtlas.textureNamed("bullet-1.png"),
            textureAtlas.textureNamed("bullet-2.png"),
            textureAtlas.textureNamed("bullet-3.png")
        ]
        let flyAction = SKAction.animateWithTextures(flyFrames, timePerFrame: 0.05)
        flyAnimation = SKAction.sequence([
            SKAction.repeatAction(flyAction, count: 10),
            SKAction.waitForDuration(0.01),
            SKAction.removeFromParent()
        ])
    }
    
    func onTap() {}
}