//
//  Ultilities.swift
//  Pierre Penguin Escapes the Antarctic
//
//  Created by Jie Zhou on 11/19/15.
//  Copyright © 2015 ThinkingSwiftly.com. All rights reserved.
//
import SpriteKit

class Utilities {

    // Retun a Double between firstNum~secondNum
    static func randomDouble(firstNum: Double, secondNum: Double) -> Double{
        return Double(arc4random()) / Double(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    // Retun a CGFloat between firstNum~secondNum
    static func randomCGFloat(firstNum: Double, secondNum: Double) -> CGFloat{
        return CGFloat(randomDouble(firstNum, secondNum: secondNum))
    }
    
    // Retun a Int
    static func randomInt (firstNum: Int , secondNum: Int) -> Int {
        return firstNum + Int(arc4random_uniform(UInt32(secondNum - firstNum + 1)))
    }
    
    static func distance(p1: CGPoint, p2: CGPoint) -> CGFloat{
        let xDist = (p2.x - p1.x); //[2]
        let yDist = (p2.y - p1.y); //[3]
        let distance = sqrt((xDist * xDist) + (yDist * yDist)); //[4]
        return distance
    }
    
    
    static func minCGFloat( x1: CGFloat,  x2: CGFloat) -> CGFloat{
        if (x1 < x2) {
            return x1;
        } else {
            return x2;
        }
    }
}