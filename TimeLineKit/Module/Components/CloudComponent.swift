//
//  TagList .swift
//  PSMyAccount
//
//  Created by Thiago Alves on 19/07/18.
//  Copyright © 2018 PagSeguro. All rights reserved.
//

import UIKit

public protocol CloudComponentDelegate: class {
    func listenToChanges(of itensSelected: [TLKitItem])
}

@IBDesignable
public class CloudComponent: UIView {
    
    private var list: [TLKitItem] = []
    
    weak var delegate: CloudComponentDelegate?
    
    @IBInspectable
    public var textSize: CGFloat = 10.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var selectedStep: [TLKitItem] = [] {
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
    public var defaultColor: UIColor = UIColor.clear {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var selectedColor: UIColor = UIColor.red {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var verticalSpacing: CGFloat = 16.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var horizontalSpacing: CGFloat = 16.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var exteriorInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var edgeInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var curentRow = 0
    
    var labelInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    
    var ultimateSpaceX: CGFloat = 0
    var ultimateSpaceY: CGFloat = 0
    
    fileprivate var centerPoints = [CGRect]()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
        
        initialize()
    }
    
    func updateList(list: [TLKitItem]) {
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        self.list = list
        if self.selectedStep.count == 0 {
            self.selectedStep = self.list.filter { $0.defaultItem == true }
        }
    }
    
    func initialize () {
        // Adjusts Insets
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.gestureAction(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addElem(_ position: Int) {
        
        let item = list[position]
        
        let label = UILabel()
        label.font = UIFont(name: self.fontName, size: self.textSize)
        label.layer.cornerRadius = (textSize + labelInsets.bottom + labelInsets.top)/2
        label.layer.masksToBounds = true
        label.textColor = selectedStep.contains { $0.id == list[position].id } ? defaultColor: selectedColor
        label.backgroundColor = selectedStep.contains { $0.id == list[position].id } ? selectedColor: defaultColor
        label.layer.borderColor = selectedColor.cgColor
        label.layer.borderWidth = 1
        label.text = item.description
        label.sizeToFit()
        label.textAlignment = .center
        label.layer.masksToBounds = true
        
        let height = textSize + labelInsets.bottom + labelInsets.top
        let width = label.intrinsicContentSize.width + labelInsets.left + labelInsets.right
        
        let labelFrame = CGRect(x: CGFloat(ultimateSpaceX), y: ultimateSpaceY, width: width, height: height)
        
        label.frame = labelFrame
        centerPoints.append(labelFrame)
        
        if ultimateSpaceX + width + verticalSpacing > frame.size.width - exteriorInsets.right - exteriorInsets.left {
            
            centerPoints.removeLast()
            
            curentRow += 1
            ultimateSpaceX = exteriorInsets.left
            ultimateSpaceY += height + horizontalSpacing
            
            centerPoints.append(CGRect(x: CGFloat(ultimateSpaceX), y: ultimateSpaceY, width: width, height: height))
            
            label.frame = CGRect(x: CGFloat(ultimateSpaceX), y: ultimateSpaceY, width: width, height: height)
        }
        ultimateSpaceX += verticalSpacing + CGFloat(width)
        
        self.addSubview(label)
    }
    
    override public func draw(_ rect: CGRect) {
        
        centerPoints.removeAll()
        ultimateSpaceX = exteriorInsets.left
        ultimateSpaceY = exteriorInsets.top
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        for i in 0 ..< self.list.count {
            
            addElem(i)
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
            
            var selectedIndex = -1
            
            for (index, rect) in self.centerPoints.enumerated() {
                if rect.contains(touchPoint) {
                    selectedIndex = index
                }
            }
            
            if selectedIndex == -1 {
                return
            }
            
            if self.list[selectedIndex].unique {
                let selectedItem = self.list[selectedIndex]
                selectedStep.removeAll()
                selectedStep.append(selectedItem)
                return
            } else {
                selectedStep = selectedStep.filter({ $0.unique != true })
                
                if !checkIsSelected(index: selectedIndex) {
                    let selectedItem = self.list[selectedIndex]
                    selectedStep.append(selectedItem)
                } else {
                    if selectedStep.count == 1 {
                        return
                    }
                    
                    selectedStep = selectedStep.filter({ $0.id != list[selectedIndex].id })
                    
                }
            }
            
            self.delegate?.listenToChanges(of: self.selectedStep)
        }
        
    }
    
    func checkIsSelected(index: Int) -> Bool {
        return selectedStep.contains { $0.id == list[index].id }
    }
}
