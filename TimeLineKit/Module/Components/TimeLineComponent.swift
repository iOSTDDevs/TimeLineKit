//
//  UIAbstractComponent.swift
//  TimeLineKit
//
//  Created by Daniel Rocha on 01/10/18.
//  Copyright © 2018 Daniel Rocha. All rights reserved.
//

import UIKit

public protocol TimeLineComponentDelegate: class {
    func didSelect(item: TLKitItem)
}

extension CGPoint {
    func distanceWith(_ p: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - p.x, 2) + pow(self.y - p.y, 2))
    }
}

@IBDesignable
public class TimeLineComponent: UIControl {
    
    fileprivate var centerPoints = [CGPoint]()
    
    // MARK: Properties
    
    weak var delegate: TimeLineComponentDelegate?
    
    var stepSelected: TLKitItem?
    
    public var stepsItems: [TLKitItem] = [] {
        didSet {
            
            if self.stepSelected == nil {
                self.stepSelected = (stepsItems.filter { $0.defaultItem == true }).first
            }
            
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var textSize: CGFloat = 10.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var fontName: String = "Helvetica" {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var stepDefaultColor: UIColor = UIColor.lightGray {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var selectedStepColor: UIColor = UIColor.orange {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var selectedStep: Int = -1 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var indicatorSize: CGFloat = 14.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var selectedIndicatorSize: CGFloat = 20.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var lineWidth: CGFloat = 1.0 {
        didSet {
            self.adjustEdgeInsets()
            self.setNeedsDisplay()
        }
    }
    
    public var edgeInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            self.adjustEdgeInsets()
        }
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
        
        self.initialize()
    }
    
    func initialize() {
        self.adjustEdgeInsets()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.gestureAction(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func adjustEdgeInsets() {
        if edgeInsets.top < (lineWidth/2) {
            edgeInsets = UIEdgeInsets(top: lineWidth/2, left: edgeInsets.left, bottom: edgeInsets.bottom, right: edgeInsets.right)
            self.setNeedsDisplay()
        }
        if edgeInsets.left < (lineWidth/2) {
            edgeInsets = UIEdgeInsets(top: edgeInsets.top, left: lineWidth/2, bottom: edgeInsets.bottom, right: edgeInsets.right)
            self.setNeedsDisplay()
        }
        if edgeInsets.bottom < (lineWidth/2) {
            edgeInsets = UIEdgeInsets(top: edgeInsets.top, left: edgeInsets.left, bottom: lineWidth/2, right: edgeInsets.right)
            self.setNeedsDisplay()
        }
        if edgeInsets.right < (lineWidth/2) {
            edgeInsets = UIEdgeInsets(top: edgeInsets.top, left: edgeInsets.left, bottom: edgeInsets.bottom, right: lineWidth/2)
            self.setNeedsDisplay()
        }
    }
    
    // MARK: Drawing
    
    func pathForStepWithIndex(_ step: Int) -> (UIBezierPath) {
        let indicatorPositionWeight = Double(40.0)
        let size = self.indicatorSize
        let delta = Float(self.frame.size.width - self.edgeInsets.left - self.edgeInsets.right - size - CGFloat(indicatorPositionWeight))
        let offset = Float(step) * (delta / Float(self.stepsItems.count - 1))
        let x = CGFloat( Double(self.edgeInsets.left) + Double(offset) + (indicatorPositionWeight / 2))
        let y = (bounds.height) / 2
        
        centerPoints.append(CGPoint(x: x, y: y))
        
        let font = UIFont(name: self.fontName, size: self.textSize)
        let text = self.stepsItems[step].description
        
        let textStyle = NSMutableParagraphStyle.default.mutableCopy()
        
        if let actualFont = font {
            
            let foregroundColor = self.stepsItems[step].id == self.stepSelected?.id ? self.selectedStepColor : self.stepDefaultColor
            
            let textFontAttributes = [
                NSAttributedString.Key.font: actualFont,
                NSAttributedString.Key.foregroundColor: foregroundColor,
                NSAttributedString.Key.paragraphStyle: textStyle
            ]
            
            let textWidth = text.size(withAttributes: textFontAttributes)
            let textX = (((x * 2) + size) - textWidth.width) / 2
            let textY = CGFloat(10.0)
            let textRect = CGRect(x: textX, y: textY, width: textWidth.width, height: size * 2)
            
            text.draw(in: textRect, withAttributes: textFontAttributes)
        }
        
        let indicatorPositionY = CGFloat(36.0)
        
        return UIBezierPath(ovalIn: CGRect(x: x, y: indicatorPositionY, width: size, height: size))
    }
    
    func pathForSelectedWitIndex(_ step: Int) -> UIBezierPath {
        
        let indicatorPositionWeight = Double(40.0)
        let size = self.indicatorSize
        let delta = Float(self.frame.size.width - self.edgeInsets.left - self.edgeInsets.right - size - CGFloat(indicatorPositionWeight))
        let offset = Float(step) * (delta / Float(self.stepsItems.count - 1))
        let x = CGFloat( Double(self.edgeInsets.left) + Double(offset) + (indicatorPositionWeight / 2))
        
        let posX = ((x * 2) + size) / 2
        
        let indicatorPositionY = CGFloat(36.0)
        
        let y = indicatorPositionY + (size/2)
        let centerPoint = CGPoint(x: posX, y: y)
        return UIBezierPath(arcCenter: centerPoint, radius: selectedIndicatorSize/2, startAngle: 0, endAngle: 360, clockwise: true)
    }
    
    func linePathForStepWithIndex(_ step: Int) -> (UIBezierPath) {
        let size = self.selectedIndicatorSize
        let indicatorPositionWeight = Double(40.0)
        let selectedIndicatorSpace = 5.0
        
        let delta = (Double(self.frame.size.width) - Double(edgeInsets.left - edgeInsets.right)
            - Double(size) - indicatorPositionWeight)
            / Double(self.stepsItems.count - 1)
        
        let offset = Double(step) * delta
        
        var space = selectedIndicatorSpace
        
        let x = Double(self.edgeInsets.left) + Double(size) + offset + (indicatorPositionWeight / 2) + space
        let y = Double(self.edgeInsets.top) + Double(self.indicatorSize / 2) + 36.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: y))
        
        space = selectedIndicatorSpace
        
        let lineWeight = self.stepsItems[step].id == self.stepSelected?.id ? 18.0 : 19.0
        let lineX = Double(offset) + Double(delta) + lineWeight - space
        
        path.addLine(to: CGPoint(x: lineX, y: y))
        
        return path
    }
    
    override public func draw(_ rect: CGRect) {
        self.tintColor.setStroke()
        
        if self.stepsItems.count == 0 {
            return
        }
        
        for i in 0 ..< self.stepsItems.count - 1 {
            let linePath = self.linePathForStepWithIndex(i)
            linePath.lineWidth = self.lineWidth
            linePath.stroke()
        }
        
        for i in 0 ..< self.stepsItems.count {
            let path = self.pathForStepWithIndex(i)
            
            if self.stepsItems[i].id == self.stepSelected?.id {
                self.selectedStepColor.setFill()
                path.lineWidth = 0
                
                let circularPath = pathForSelectedWitIndex(i)
                circularPath.stroke()
                
            } else {
                self.stepDefaultColor.setFill()
                path.lineWidth = self.lineWidth
            }
            
            path.fill()
            
            path.stroke()
        }
    }
    
    /**
     Respond to the user action
     - parameter gestureRecognizer: The gesture recognizer responsible for the action
     */
    @objc func gestureAction(_ gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizer.State.ended ||
            gestureRecognizer.state == UIGestureRecognizer.State.changed {
            
            let touchPoint = gestureRecognizer.location(in: self)
            
            var smallestDistance = CGFloat(Float.infinity)
            
            var selectedIndex = -1
            
            for (index, point) in self.centerPoints.enumerated() {
                let distance = touchPoint.distanceWith(point)
                if distance < smallestDistance {
                    smallestDistance = distance
                    selectedIndex = index
                }
            }
            
            if selectedIndex > -1 && self.selectedStep != selectedIndex {
                self.centerPoints.removeAll()
                self.selectedStep = selectedIndex
                self.stepSelected = self.stepsItems[selectedIndex]
                self.delegate?.didSelect(item: self.stepSelected!)
            }
        }
    }
}
