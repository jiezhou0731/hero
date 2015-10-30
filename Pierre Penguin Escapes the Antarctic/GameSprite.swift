//
//  GameSprite.swift
//  Pierre Penguin Escapes the Antarctic
//

import SpriteKit

protocol GameSprite {
    var textureAtlas: SKTextureAtlas { get set }
    func spawn(parentNode: SKNode, position: CGPoint, size: CGSize)
    func onTap()
}