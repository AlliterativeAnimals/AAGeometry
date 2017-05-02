//
//  AAAngle.swift
//  AAGeometry
//

import AAFoundation
import CoreGraphics

public struct AAAngle: Comparable, CustomStringConvertible {
    public let unitAngle: CGFloat
    
    public static let zero = AAAngle(unitAngle: 0)
    public static let fullCircle = AAAngle(unitAngle: 1)
    
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
    
    public var clamped: AAAngle {
        let upperBound: CGFloat = 1
        let lowerBound: CGFloat = 0
        
        if self.unitAngle > upperBound || self.unitAngle < lowerBound {
            return AAAngle(unitAngle: self.unitAngle.clamped(to: lowerBound...upperBound))
        }
        
        return self
    }
    
    public var description: String {
        return "LPAngle(unit: \(self.unitAngle))"
    }
    
    public static func <(lhs: AAAngle, rhs: AAAngle) -> Bool {
        return lhs.unitAngle < rhs.unitAngle
    }
    
    public static func >(lhs: AAAngle, rhs: AAAngle) -> Bool {
        return lhs.unitAngle > rhs.unitAngle
    }
    
    public static func <=(lhs: AAAngle, rhs: AAAngle) -> Bool {
        return lhs.unitAngle <= rhs.unitAngle
    }
    
    public static func >=(lhs: AAAngle, rhs: AAAngle) -> Bool {
        return lhs.unitAngle >= rhs.unitAngle
    }
    
    public static func ==(lhs: AAAngle, rhs: AAAngle) -> Bool {
        return lhs.unitAngle == rhs.unitAngle
    }
    
    public static func +(lhs: AAAngle, rhs: AAAngle) -> AAAngle {
        return AAAngle(unitAngle: lhs.unitAngle + rhs.unitAngle)
    }
    
    public static func -(lhs: AAAngle, rhs: AAAngle) -> AAAngle {
        return AAAngle(unitAngle: lhs.unitAngle - rhs.unitAngle)
    }
}
