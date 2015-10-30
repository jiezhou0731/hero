//
//  MadFly.swift
//  Pierre Penguin Escapes the Antarctic
//

import SpriteKit

class Gun{
    init(){
    }
    
    func shootBullet(){
        var  bullet = Bullet()
        bullet.spawn((ObjectPool.gameScene?.world)!, position: (ObjectPool.gameScene?.player.position)!)
    }
    
    
    func sceneTouchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) ->Bool {
        for touch in (touches) {
            shootBullet()
            return true
        }
        return false
    }
}