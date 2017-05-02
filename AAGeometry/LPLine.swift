//
//  Line.swift
//  Line Puzzle
//
//  Created by David Godfrey on 07/01/2017.
//  Copyright © 2017 Alliterative Animals. All rights reserved.
//

import AAFoundation
import CoreGraphics
import UIKit

public protocol LPTubeProtocol {
    associatedtype LineType: LPUndirectedLineProtocol
    var lines: [ LineType ] { get }
    init(line: LineType, radius: CGFloat)
}

public extension LPTubeProtocol {
    public var asClosedPath: UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: self.lines[0].sortedPoints[0])
        path.addLine(to: self.lines[0].sortedPoints[1])
        path.addLine(to: self.lines[1].sortedPoints[1]) // second line is reversed so we get 'U' shape not 'N'
        path.addLine(to: self.lines[1].sortedPoints[0])
        path.close() // Close it up, from 'U' to '[]'
        
        return path
    }
}

public class LPUndirectedTube: LPTubeProtocol {
    public typealias LineType = LPUndirectedLine
    public let lines: [ LPUndirectedLine ]
    
    public required init(line: LPUndirectedLine, radius: CGFloat) {
        let currentStart = line.sortedPoints[0]
        let currentEnd = line.sortedPoints[1]
        
        var orthogonalVector: CGVector!
        
        // Can we simplify where they're horizontal/vertical lines?
        if currentStart.x == currentEnd.x { // Line along X
            orthogonalVector = CGVector(dx: radius, dy: 0)
        } else if currentStart.y == currentEnd.y { // Line along Y
            orthogonalVector = CGVector(dx: 0, dy: radius)
        } else { // No way around it, need to calculate the vector!
            // Find an orthogonal line
            let orthogonalAngle = LPAngle(unitAngle: line.angle.unitAngle + 0.25)
            let orthogonalLine = LPUndirectedLine(point: currentStart, angle: orthogonalAngle, length: radius)
            // Convert it to a vector
            orthogonalVector = CGVector(dx: orthogonalLine.dx, dy: orthogonalLine.dy)
        }
        
        // Now move the line points by that vector, and its inverse, to find the two new lines either side of the given one
        let strangeLine = line.movedBy(vector: orthogonalVector)
        let charmLine = line.movedBy(vector: orthogonalVector.inverse)
        
        self.lines = [ strangeLine, charmLine ]
    }
}

public class LPDirectedTube: LPTubeProtocol {
    public typealias LineType = LPDirectedLine
    
    public let lines: [ LPDirectedLine ]
    
    public required init(line: LPDirectedLine, radius: CGFloat) {
        let currentStart = line.sortedPoints[0]
        let currentEnd = line.sortedPoints[1]
        
        var orthogonalVector: CGVector!
        
        // Can we simplify where they're horizontal/vertical lines?
        if currentStart.x == currentEnd.x { // Line along X
            orthogonalVector = CGVector(dx: radius, dy: 0)
        } else if currentStart.y == currentEnd.y { // Line along Y
            orthogonalVector = CGVector(dx: 0, dy: radius)
        } else { // No way around it, need to calculate the vector!
            // Find an orthogonal line
            let orthogonalAngle = LPAngle(unitAngle: line.angle.unitAngle + 0.25)
            let orthogonalLine = LPUndirectedLine(point: currentStart, angle: orthogonalAngle, length: radius)
            // Convert it to a vector
            orthogonalVector = CGVector(dx: orthogonalLine.dx, dy: orthogonalLine.dy)
        }
        
        // Now move the line points by that vector, and its inverse, to find the two new lines either side of the given one
        let strangeLine = line.movedBy(vector: orthogonalVector)
        let charmLine = line.movedBy(vector: orthogonalVector.inverse)
        
        self.lines = [ strangeLine, charmLine ]
    }
}

public protocol LPUndirectedLineProtocol: Hashable, LPMinMaxPointRanged {
    var sortedPoints: Array<CGPoint> { get }
    var dx: CGFloat { get }
    var dy: CGFloat { get }
    var lengthSquared: CGFloat { get }
    var length: CGFloat { get }
    var angle: LPAngle { get }
    func isParallelTo(line: Self) -> Bool
    func intersection(with: Self) -> CGPoint?
    func clipTo(rect: CGRect) -> Self?
    func closestPointOnLineTo(point: CGPoint) -> CGPoint
    func vectorTo(point: CGPoint) -> CGVector
    func movedBy(vector: CGVector) -> Self
    func applying(_: CGAffineTransform) -> Self
}

public extension LPUndirectedLineProtocol {
    public func closestPointOnLineTo(point: CGPoint) -> CGPoint {
        let pointArray = Array(self.sortedPoints)
        let first = pointArray.first!
        let second = pointArray.last!
        
        let vectorFirstToPoint = CGVector(dx: point.x - first.x, dy: point.y - first.y)
        let vectorOfLine = CGVector(dx: second.x - first.x, dy: second.y - first.y)
        
        let lineSquareMagnitude = vectorOfLine.squareMagnitude
        
        var distanceAlongLine: CGFloat = -1;
        if lineSquareMagnitude != 0 {
            distanceAlongLine = vectorOfLine.getDotProduct(withVector: vectorFirstToPoint) / lineSquareMagnitude
        }
        
        if distanceAlongLine <= 0 {
            return first // Can't go off the beginning of the line; clip it to the line's startpoint.
        } else if distanceAlongLine >= 1 {
            return second // Shot off the end of the line! clip it to the line's endpoint.
        } else {
            // The good shit. Calculating a real point.
            let scaledDistanceVector = vectorOfLine.scale(byMultiplier: distanceAlongLine)
            return CGPoint(x: first.x + scaledDistanceVector.dx, y: first.y + scaledDistanceVector.dy)
        }
    }
    
    public func vectorTo(point: CGPoint) -> CGVector {
        return LPDirectedLine(
            start: self.closestPointOnLineTo(point: point),
            end: point
        )
            .vector
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func intersection(with other: Self) -> CGPoint? {
        let myPoints = Array(self.sortedPoints)
        var theirPoints = Array(other.sortedPoints)
        
        let myFirstX = myPoints[0].x
        let mySecondX = myPoints[1].x
        let myFirstY = myPoints[0].y
        let mySecondY = myPoints[1].y
        
        let theirFirstX = theirPoints[0].x
        let theirSecondX = theirPoints[1].x
        let theirFirstY = theirPoints[0].y
        let theirSecondY = theirPoints[1].y
        let distance = (mySecondX - myFirstX) * (theirSecondY - theirFirstY) - (mySecondY - myFirstY) * (theirSecondX - theirFirstX)
        if distance == 0 {
            // Lines are the same!
            return nil
        }
        
        let u = ((theirFirstX - myFirstX) * (theirSecondY - theirFirstY) - (theirFirstY - myFirstY) * (theirSecondX - theirFirstX)) / distance
        let v = ((theirFirstX - myFirstX) * (mySecondY - myFirstY) - (theirFirstY - myFirstY) * (mySecondX - myFirstX)) / distance
        
        if (u < 0.0 || u > 1.0 || v < 0.0 || v > 1.0) {
            // Line sections don't intersect!
            return nil
        }
        
        return CGPoint(x: myFirstX + u * (mySecondX - myFirstX), y: myFirstY + u * (mySecondY - myFirstY))
    }
    
    public func isParallelTo(line: Self) -> Bool {
        // Parallell-ness is not directional, so only consider 180 degrees worth.
        let range: ClosedRange<CGFloat> = 0...0.5
        return self.angle.unitAngle.clamped(to: range) == line.angle.unitAngle.clamped(to: range)
    }
    
    public func couldIntersectWith(_ rectLike: LPMinMaxPointRanged) -> Bool {
        let isAboveRect   = rectLike.maxY < self.minY
        let isBelowRect   = rectLike.minY > self.maxY
        let isRightOfRect = rectLike.maxX < self.minX
        let isLeftOfRect  = rectLike.minX > self.maxX
        
        return !(isAboveRect || isRightOfRect || isLeftOfRect || isBelowRect)
    }
    
    public func toBezierPath(withStrokeWidth strokeWidth: CGFloat) -> UIBezierPath {
        let points = self.getTubePoints(withRadius: strokeWidth / 2)

        guard points.count == 4 else { fatalError("Expecting four points for a rect") }
        
        let path = UIBezierPath()
        path.move(to: points[0])
        path.addLine(to: points[1])
        path.addLine(to: points[2])
        path.addLine(to: points[3])
        path.close()
        
        return path
    }
    
    public func getTubePoints(withRadius radius: CGFloat) -> [CGPoint] {
        let currentStart = self.sortedPoints[0]
        let currentEnd = self.sortedPoints[1]
        
        var points: [CGPoint]!
        
        // Can we simplify where they're horizontal/vertical lines?
        if currentStart.x == currentEnd.x { // Line along X
            points = [
                CGPoint(x: currentStart.x + radius, y: currentStart.y),
                CGPoint(x: currentStart.x - radius, y: currentStart.y),
                CGPoint(x: currentEnd.x - radius, y: currentEnd.y),
                CGPoint(x: currentEnd.x + radius, y: currentEnd.y),
            ]
        } else if currentStart.y == currentEnd.y { // Line along Y
            points = [
                CGPoint(x: currentStart.x, y: currentStart.y + radius),
                CGPoint(x: currentStart.x, y: currentStart.y - radius),
                CGPoint(x: currentEnd.x, y: currentEnd.y - radius),
                CGPoint(x: currentEnd.x, y: currentEnd.y + radius),
            ]
        } else { // Another angle!
            // Draw orthogonal lines out from start/end points
            let orthogonalAngle = LPAngle(unitAngle: self.angle.unitAngle + 0.25)
            let startStrange = LPUndirectedLine(point: currentStart, angle: orthogonalAngle, length: radius)
            let startCharm = LPUndirectedLine(point: currentStart, angle: orthogonalAngle, length: -radius)
            let endStrange = LPUndirectedLine(point: currentEnd, angle: orthogonalAngle, length: radius)
            let endCharm = LPUndirectedLine(point: currentEnd, angle: orthogonalAngle, length: -radius)
            
            // Get the points that DONT match the current line, they're our box!
            points = [
                startStrange.sortedPoints.filter({ $0 != currentStart }).first!,
                startCharm.sortedPoints.filter({ $0 != currentStart }).first!,
                endCharm.sortedPoints.filter({ $0 != currentEnd }).first!,
                endStrange.sortedPoints.filter({ $0 != currentEnd }).first!,
            ]
        }
        
        guard points != nil else { fatalError("Did not generate points array! This should never happen.") }

        return points
    }
}

public struct LPUndirectedLine: LPUndirectedLineProtocol, Hashable, LPMinMaxPointRanged {
    public let minX: CGFloat
    public let maxX: CGFloat
    public let minY: CGFloat
    public let maxY: CGFloat
    public let sortedPoints: Array<CGPoint>
    
    public init(point: CGPoint, anotherPoint: CGPoint) {
        let unsortedPoints = [ point, anotherPoint ]
        self.sortedPoints = unsortedPoints.sorted { a, b in
            // Sort by min(X), or by min(Y) if X is equal.
            return a.x < b.x || (a.x == b.x && a.y <= b.y)
        }
        
        self.minX = min(point.x, anotherPoint.x)
        self.maxX = max(point.x, anotherPoint.x)
        self.minY = min(point.y, anotherPoint.y)
        self.maxY = max(point.y, anotherPoint.y)
    }

    public init(point: CGPoint, angle: LPAngle, length: CGFloat) {
        let radians = angle.radians
        let anotherPoint = CGPoint(x: point.x + sin(radians) * length, y: point.y + cos(radians) * length)
        let unsortedPoints = [ point, anotherPoint ]
        self.sortedPoints = unsortedPoints.sorted { a, b in
            // Sort by min(X), or by min(Y) if X is equal.
            return a.x < b.x || (a.x == b.x && a.y <= b.y)
        }
        
        self.minX = min(point.x, anotherPoint.x)
        self.maxX = max(point.x, anotherPoint.x)
        self.minY = min(point.y, anotherPoint.y)
        self.maxY = max(point.y, anotherPoint.y)
    }
    
    public var dx: CGFloat {
        return self.maxX - self.minX
    }
    
    public var dy: CGFloat {
        return self.maxY - self.minY
    }
    
    // faster, still allows comparison, but isn't absolute.
    public var lengthSquared: CGFloat {
        return pow(self.dx, 2) + pow(self.dy, 2)
    }
    
    public var length: CGFloat {
        return pow(self.lengthSquared, 0.5)
    }
    
    public var angle: LPAngle {
        return LPAngle(radians: atan2(self.dx, self.dy))
    }
    
    public var hashValue: Int {
        return "(\(self.sortedPoints[0]),\(self.sortedPoints[1]))".hashValue
    }

    public func clipTo(rect: CGRect) -> LPUndirectedLine? {
        let pointA = self.sortedPoints.first!
        let pointB = self.sortedPoints.last!
        
        if !self.couldIntersectWith(rect) {
            return nil
        }

        let aEscapes = !rect.contains(pointA, includingOnBoundary: true)
        let bEscapes = !rect.contains(pointB, includingOnBoundary: true)

        if (aEscapes || bEscapes) {
            let rectEdges = [ CGRectEdge.minXEdge, .maxXEdge, .minYEdge, .maxYEdge ].map({ ( $0, rect.edgeLine(along: $0) ) })
            
            var newPoints = [ pointA, pointB ]
            
            for (edgeType, edgeLine) in rectEdges {
                var safePoint: CGPoint!
                switch edgeType {
                case .maxXEdge:
                    safePoint = newPoints[0].x > edgeLine.maxX ? newPoints[1] : newPoints[0]
                case .maxYEdge:
                    safePoint = newPoints[0].y > edgeLine.maxY ? newPoints[1] : newPoints[0]
                case .minXEdge:
                    safePoint = newPoints[0].x < edgeLine.minX ? newPoints[1] : newPoints[0]
                case .minYEdge:
                    safePoint = newPoints[0].y < edgeLine.minY ? newPoints[1] : newPoints[0]
                }
                
                if let intersectionPoint = self.intersection(with: edgeLine) {
                    newPoints = [ safePoint, intersectionPoint ]
                }
            }
            
            return LPUndirectedLine(point: newPoints[0], anotherPoint: newPoints[1])
        } else {
            return self
        }
    }
    
    public static func ==(lhs: LPUndirectedLine, rhs: LPUndirectedLine) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func applying(_ transform: CGAffineTransform) -> LPUndirectedLine {
        let newPoints = self.sortedPoints.map({ $0.applying(transform) })
        return LPUndirectedLine(point: newPoints[0], anotherPoint: newPoints[1])
    }
    
    public func movedBy(vector: CGVector) -> LPUndirectedLine {
        return LPUndirectedLine(point: self.sortedPoints[0].movedBy(vector: vector), anotherPoint: self.sortedPoints[1].movedBy(vector: vector))
    }
}

public struct LPDirectedLine: LPUndirectedLineProtocol {
    public var sortedPoints: Array<CGPoint> {
        let unsortedPoints = [ self.start, self.end ]
        return unsortedPoints.sorted { a, b in
            // Sort by min(X), or by min(Y) if X is equal.
            return a.x < b.x || (a.x == b.x && a.y <= b.y)
        }
    }
    
    public let start: CGPoint
    public let end: CGPoint
    public let minX: CGFloat
    public let maxX: CGFloat
    public let minY: CGFloat
    public let maxY: CGFloat
    
    public var dx: CGFloat { return self.end.x - self.start.x }
    public var dy: CGFloat { return self.end.y - self.start.y }
    public var lengthSquared: CGFloat { return self.undirected.lengthSquared }
    
    public var length: CGFloat {
        return self.undirected.length
    }
    
    public var undirected: LPUndirectedLine {
        return LPUndirectedLine(point: self.start, anotherPoint: self.end)
    }
    
    public var reversed: LPDirectedLine {
        return LPDirectedLine(start: self.end, end: self.start)
    }
    
    public var angle: LPAngle {
        return LPAngle.init(radians: atan2(self.dx, self.dy))
    }
    
    public var vector: CGVector {
        return CGVector(dx: self.dx, dy: self.dy)
    }
    
    public func isParallelTo(line: LPDirectedLine) -> Bool {
        return self.angle == line.angle
    }
    
    public init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
        
        self.minX = min(start.x, end.x)
        self.maxX = max(start.x, end.x)
        self.minY = min(start.y, end.y)
        self.maxY = max(start.y, end.y)
    }

    public init(start: CGPoint, angle: LPAngle, length: CGFloat) {
        self.start = start
        let radians = angle.radians
        self.end = CGPoint(
            x: start.x + sin(radians) * length,
            y: start.y + cos(radians) * length
        )
        
        self.minX = min(start.x, end.x)
        self.maxX = max(start.x, end.x)
        self.minY = min(start.y, end.y)
        self.maxY = max(start.y, end.y)
    }
    
    public static func ==(lhs: LPDirectedLine, rhs: LPDirectedLine) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    // Line intersection is not directional. Either crosses or doesn't.
    public func intersection(with other: LPUndirectedLine) -> CGPoint? {
        return self.undirected.intersection(with: other)
    }
    
    public func intersection(with other: LPDirectedLine) -> CGPoint? {
        return self.intersection(with: other.undirected)
    }
    
    public var hashValue: Int { return "\(self.start) to \(self.end)".hashValue }
    
    public func clipTo(rect: CGRect) -> LPDirectedLine? {
        
        if !self.couldIntersectWith(rect) {
            return nil
        }
        
        var start = self.start
        var end = self.end
        
        let startEscapes = !rect.contains(self.start, includingOnBoundary: true)
        let endEscapes = !rect.contains(self.end, includingOnBoundary: true)
        
        if (startEscapes || endEscapes) {
            for edgeType in [ CGRectEdge.maxXEdge, .maxYEdge, .minYEdge, .minXEdge ] {
                var replaceStart: Bool = false
                switch edgeType {
                case .maxXEdge:
                    replaceStart = start.x > rect.maxX
                case .maxYEdge:
                    replaceStart = start.y > rect.maxY
                case .minYEdge:
                    replaceStart = start.y < rect.minY
                case .minXEdge:
                    replaceStart = start.x < rect.minX
                }
                
                if let intersectionPoint = self.intersection(with: rect.edgeLine(along: edgeType)) {
                    if replaceStart {
                        start = intersectionPoint
                    } else {
                        end = intersectionPoint
                    }
                }
            }
            
            guard start != self.start || end != self.end else {
                fatalError("Could not clip to line; logic error!")
            }
            
            return LPDirectedLine(start: start, end: end)
        } else {
            return self
        }
    }
    
    public func applying(_ transform: CGAffineTransform) -> LPDirectedLine {
        return LPDirectedLine(start: self.start.applying(transform), end: self.end.applying(transform))
    }
    
    public func movedBy(vector: CGVector) -> LPDirectedLine {
        return LPDirectedLine(start: self.start.movedBy(vector: vector), end: self.end.movedBy(vector: vector))
    }
}


























