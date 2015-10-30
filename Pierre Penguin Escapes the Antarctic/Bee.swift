//
//  Bee.swift
//  Pierre Penguin Escapes the Antarctic
//

import SpriteKit

class Bee: SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"bee.atlas")
    var flyAnimation = SKAction()

    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 28, height: 24)) {
        parentNode.addChild(self)
        createAnimations()
        self.size = size
        self.position = position
        self.runAction(flyAnimation)
        
        // Attach a physics body, shaped like a circle and sized roughly to our bee
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        // Because physicsBody is an optional, we use a question mark
        // to create an optional chain. If physicsBody is nil, the entire
        // expression will return nil, instead of triggering an error
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy.rawValue
        self.physicsBody?.collisionBitMask = ~(PhysicsCategory.damagedPenguin.rawValue)
    }

    func createAnimations() {
        let flyFrames:[SKTexture] = [textureAtlas.textureNamed("bee.png"), textureAtlas.textureNamed("bee_fly.png")]
        let flyAction = SKAction.animateWithTextures(flyFrames, timePerFrame: 0.14)
        flyAnimation = SKAction.repeatActionForever(flyAction)
    }
    
    func onTap() {}
}