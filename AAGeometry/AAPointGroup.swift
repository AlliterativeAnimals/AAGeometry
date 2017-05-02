//
//  AAPointGroup.swift
//  AAGeometry
//

import AAFoundation
import UIKit

public struct AAPointGroup {
    public var points: Array<CGPoint>
    
    public init(points: Array<CGPoint>) {
        self.points = points
    }
    
    public func findPoints(inPath path: UIBezierPath) -> AAPointGroup {
        return AAPointGroup(points: self.points.filter { point in path.contains(point) })
    }
    
    public func findPoint(closestToPoint targetPoint: CGPoint) -> CGPoint? {
        var closestPoint: CGPoint?
        var distance: CGFloat?
        
        for groupPoint in self.points {
            if let previousDistance = distance {
                let newDistance = AADirectedLine(start: targetPoint, end: groupPoint).length
                if newDistance < previousDistance {
                    distance = newDistance
                    closestPoint = groupPoint
                }
            } else {
                distance = AADirectedLine(start: targetPoint, end: groupPoint).length
                closestPoint = groupPoint
            }
        }
        
        return closestPoint
    }
    
    public func hasChangedSince(previousPointGroup previous: AAPointGroup, withTolerance tolerance: CGFloat = 1) -> Bool {
        for (index, previousPoint) in previous.enumerated() {
            if !self[index].isCloseTo(point: previousPoint, withTolerance: tolerance) {
                return true // shortcut out, only needs one point out of place!
            }
        }
        
        // Didn't return, so nothing is out of tolerance! No change.
        return false
    }
}

public extension AAPointGroup {
    public var minX: CGFloat? {
        return self.points.map({ $0.x }).min()
    }

    public var minY: CGFloat? {
        return self.points.map({ $0.y }).min()
    }

    var maxX: CGFloat? {
        return self.points.map({ $0.x }).max()
    }

    var maxY: CGFloat? {
        return self.points.map({ $0.y }).max()
    }
}


// Extend LineGroup to be iterable and subscriptable. Moved out to extension just to keep things neat.
extension AAPointGroup: Collection {
    public typealias Iterator = IndexingIterator<Array<CGPoint>>
    public typealias Index = Int
    public typealias _Element = CGPoint
    
    public var startIndex: Int {
        return self.points.startIndex
    }
    
    public var endIndex: Int {
        return self.points.endIndex
    }
    
    public func makeIterator() -> IndexingIterator<Array<CGPoint>> {
        return self.points.makeIterator()
    }
    
    public var count: Int {
        return self.points.count
    }
    
    public var first: CGPoint? {
        return self.points.first
    }
    
    public var last: CGPoint? {
        return self.points.last
    }
    
    public subscript(_ index: Int) -> CGPoint {
        return self.points[index]
    }
    
    public func index(after i: Int) -> Int {
        return self.points.index(after: i)
    }
}






