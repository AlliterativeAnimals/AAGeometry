//
//  LPLineGroup.swift
//  Line Puzzle
//
//  Created by David Godfrey on 09/01/2017.
//  Copyright © 2017 Alliterative Animals. All rights reserved.
//

import AAFoundation
import UIKit

public struct LPUndirectedLineGroup: LPLineGroupProtocol {
    public typealias LineType = LPUndirectedLine
    public let lines: Array<LPUndirectedLine>
    
    public init(lines: Array<LPUndirectedLine>) {
        self.lines = lines
    }
}

public struct LPDirectedLineGroup: LPLineGroupProtocol {
    public typealias LineType = LPDirectedLine
    public let lines: Array<LPDirectedLine>
    
    public init(lines: Array<LPDirectedLine>) {
        self.lines = lines
    }
    
    public func findLines(startingInPath path: UIBezierPath) -> LPDirectedLineGroup {
        return LPDirectedLineGroup(lines: self.lines.filter({ path.contains($0.start) }))
    }
    
    public func findLines(endingInPath path: UIBezierPath) -> LPDirectedLineGroup {
        return LPDirectedLineGroup(lines: self.lines.filter({ path.contains($0.end) }))
    }
    
    public var undirectedLineGroup: LPUndirectedLineGroup { return LPUndirectedLineGroup(lines: self.lines.map({ $0.undirected })) }
}

public protocol LPLineGroupProtocol: Collection {
    associatedtype LineType: LPUndirectedLineProtocol
    typealias Iterator = IndexingIterator<Array<LineType>>
    typealias Index = Int
    typealias _Element = LineType
    
    var lines: Array<LineType> { get }
    init(lines: Array<LineType>)
    
    func findLines(startingOrEndingInPath path: UIBezierPath) -> Self
    func findLines(startingOrEndingAt point: CGPoint, withTolerance tolerance: CGFloat) -> Self
    func findLine(closestToPoint point: CGPoint) -> LineType?
}

public extension LPLineGroupProtocol {
    public func findLines(startingOrEndingInPath path: UIBezierPath) -> Self {
        let filtered = lines.filter({ $0.sortedPoints.contains(where: { path.contains($0) }) })
        return Self(lines: filtered)
    }

    public func findLines(startingOrEndingAt point: CGPoint, withTolerance tolerance: CGFloat = 1.0) -> Self {
        let halfTolerance = tolerance / 2
        let toleranceCorrectionVector = CGVector(dx: -halfTolerance, dy: -halfTolerance)
        let toleranceRect = CGRect(origin: point.movedBy(vector: toleranceCorrectionVector), size: CGSize(width: tolerance, height: tolerance))

        let filtered = lines.filter { line in
            return toleranceRect.contains(anyOf: line.sortedPoints)
        }

        return Self(lines: filtered)
    }

    public func findLine(closestToPoint point: CGPoint) -> LineType? {
        var closestLine: LineType?
        var distance: CGFloat?

        for line in lines {
            if let previousDistance = distance {
                let newDistance = line.vectorTo(point: point).squareMagnitude
                if newDistance < previousDistance {
                    distance = newDistance
                    closestLine = line
                }
            } else {
                distance = line.vectorTo(point: point).squareMagnitude
                closestLine = line
            }
        }

        return closestLine
    }
    
    public func applying(_ transform: CGAffineTransform) -> Self {
        return Self(lines: self.lines.map({ $0.applying(transform) }) )
    }
}


// Extend LineGroup to be iterable and subscriptable. Moved out to extension just to keep things neat.
public extension LPLineGroupProtocol {
    public var startIndex: Int {
        return self.lines.startIndex
    }

    public var endIndex: Int {
        return self.lines.endIndex
    }

    public func makeIterator() -> IndexingIterator<Array<LineType>> {
        return self.lines.makeIterator()
    }

    public var count: Int {
        return self.lines.count
    }

    public var first: LineType? {
        return self.lines.first
    }

    public var last: LineType? {
        return self.lines.last
    }

    public subscript(_ index: Int) -> LineType {
        return self.lines[index]
    }

    public func index(after i: Int) -> Int {
        return self.lines.index(after: i)
    }
}



























