import SpriteKit

class RoomFrameY: SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"map.atlas")
    var flyAnimation = SKAction()

    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 3, height: 500)) {
        parentNode.addChild(self)
        createAnimations()
        self.size = size
        self.position = position
        self.runAction(flyAnimation)
        
        self.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.geo.rawValue
        self.physicsBody?.collisionBitMask = ~PhysicsCategory.geo.rawValue
    }

    func createAnimations() {
        let flyFrames:[SKTexture] = [textureAtlas.textureNamed("roomFrameY.png")]
        let flyAction = SKAction.animateWithTextures(flyFrames, timePerFrame: 0.14)
        flyAnimation = SKAction.repeatActionForever(flyAction)
    }
    
    func onTap() {}
}