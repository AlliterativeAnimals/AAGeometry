//
//  Angle.swift
//  Line Puzzle
//
//  Created by David Godfrey on 07/01/2017.
//  Copyright © 2017 Alliterative Animals. All rights reserved.
//

import AAFoundation
import CoreGraphics

public struct LPAngle: Comparable, CustomStringConvertible {
    public let unitAngle: CGFloat
    
    public static let zero = LPAngle(unitAngle: 0)
    public static let fullCircle = LPAngle(unitAngle: 1)
    
    public init(unitAngle: CGFloat) {
        self.unitAngle = unitAngle
    }
    
    public init(degrees: CGFloat) {
        self.init(unitAngle: degrees / 360)
    }
    
    public init(radians: CGFloat) {
        self.init(unitAngle: radians / .pi / 2)
    }
    
    public var degrees: CGFloat {
        return unitAngle * 360
    }
    
    public var radians: CGFloat {
        return unitAngle * 2.0 * .pi
    }
    
    public var clamped: LPAngle {
        let upperBound: CGFloat = 1
        let lowerBound: CGFloat = 0
        
        if self.unitAngle > upperBound || self.unitAngle < lowerBound {
            return LPAngle(unitAngle: self.unitAngle.clamped(to: lowerBound...upperBound))
        }
        
        return self
    }
    
    public var description: String {
        return "LPAngle(unit: \(self.unitAngle))"
    }
    
    public static func <(lhs: LPAngle, rhs: LPAngle) -> Bool {
        return lhs.unitAngle < rhs.unitAngle
    }
    
    public static func >(lhs: LPAngle, rhs: LPAngle) -> Bool {
        return lhs.unitAngle > rhs.unitAngle
    }
    
    public static func <=(lhs: LPAngle, rhs: LPAngle) -> Bool {
        return lhs.unitAngle <= rhs.unitAngle
    }
    
    public static func >=(lhs: LPAngle, rhs: LPAngle) -> Bool {
        return lhs.unitAngle >= rhs.unitAngle
    }
    
    public static func ==(lhs: LPAngle, rhs: LPAngle) -> Bool {
        return lhs.unitAngle == rhs.unitAngle
    }
    
    public static func +(lhs: LPAngle, rhs: LPAngle) -> LPAngle {
        return LPAngle(unitAngle: lhs.unitAngle + rhs.unitAngle)
    }
    
    public static func -(lhs: LPAngle, rhs: LPAngle) -> LPAngle {
        return LPAngle(unitAngle: lhs.unitAngle - rhs.unitAngle)
    }
}
