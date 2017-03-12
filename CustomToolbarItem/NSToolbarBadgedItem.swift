//
//  NSToolbarBadgedItem.swift
//  CustomToolbarItem
//
//  Created by Marco Chiang on 3/10/17.
//  Copyright © 2017 CustomToolbarItem. All rights reserved.
//

import Cocoa
import CoreGraphics

class NSToolbarBadgedItem: NSToolbarItem {
    var primary: NSImage!
    var cache: NSImage!
    
    var badgeValue: String
    var badgeFontName: String
    var badgeTextColor: NSColor
    
    var badgeFillColor: NSColor
    
    override init(itemIdentifier: String) {

        self.badgeValue = "0"
        self.badgeFillColor = NSColor.red
        self.badgeTextColor = NSColor.white
        self.badgeFontName = "Helvetica-Bold"
        
        super.init(itemIdentifier: itemIdentifier)
        
    }
    
    override func validate() {
        self.isEnabled = true
    }
    
    override func awakeFromNib() {
        if self.responds(to: #selector(self.awakeFromNib)) {
            super.awakeFromNib()
        }
        
        self.primary = self.image
        self.refreshBadge()
    }
    
    func setBadgedImage(_ image: NSImage) {
        self.primary = image
        if self.badgeValue.characters.count > 0 {
            self.cache = nil
            super.image = self.badgeImage(self.badgeValue)
        }
        else {
            super.image = image
        }
    }
    
    func setBadge(_ badgeValue: String) {
        if !self.badgeValue.isEqual(badgeValue) {
            if self.badgeValue.characters.count > 0 {
                super.image = self.badgeImage(badgeValue)
            }
            else {
                super.image = self.primary
            }
            self.badgeValue = badgeValue
        }
    }
    
    func refreshBadge() {
        if self.badgeValue.characters.count > 0 {
            if let primary = self.primary {
                self.cache = self.renderImage(primary, withBadge: self.badgeValue)
                super.image = self.cache
            }
        }
    }
    
    func badgeImage(_ badgeValue: String) -> NSImage {
        if !self.badgeValue.isEqual(badgeValue) || self.cache == nil {
            self.cache = self.renderImage(self.primary, withBadge: badgeValue)
        }
        return self.cache
    }
    
    func renderImage(_ image: NSImage, withBadge badge: String) -> NSImage {
        let locations: [CGFloat] = [1.0, 0.5, 0.0]
        let colors = [self.badgeFillColor.cgColor]
        let colorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        let gradient: CGGradient? = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        let paragraphStyle = NSMutableParagraphStyle.default()
        
        let newImage = NSImage(size: image.size)
        for rep: NSImageRep in image.representations {
            let size: NSSize = rep.size
            let newRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSDeviceRGBColorSpace, bytesPerRow: Int(size.width)*4, bitsPerPixel: 32)
            let ctx = NSGraphicsContext(bitmapImageRep: newRep!)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.setCurrent(ctx)
            
            if let context = NSGraphicsContext.current()?.cgContext {
                context.saveGState()
                context.setAllowsFontSmoothing(true)
                context.setAllowsAntialiasing(true)
                context.setAllowsFontSubpixelQuantization(true)
                context.setAllowsFontSubpixelPositioning(true)
                context.setBlendMode(CGBlendMode.copy)
                
                var imageRect = NSMakeRect(0, 0, size.width, size.height)
                
                let ref = image.cgImage(forProposedRect: &imageRect, context: NSGraphicsContext.current(), hints: nil)
                context.draw(ref!, in: imageRect)
                
                let iconsize = size.width * 0.5
                let lineWidth = max(1, iconsize * 0.11)
                let pointSize = iconsize - (lineWidth * 2.0)
                var radius = iconsize * 0.5
                
                // Draw at top right corner
                let position = (size.width) - CGFloat(iconsize)
                let indent: NSPoint = NSMakePoint(position, position)
                var rect: NSRect = NSMakeRect(indent.x, indent.y, CGFloat(iconsize), CGFloat(iconsize))
                
                // work out the area
                let font = NSFont(name: self.badgeFontName, size: CGFloat(pointSize))
                
                // color the text
                var attr: [AnyHashable: Any]? = nil
                attr = [NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: font!, NSForegroundColorAttributeName: self.badgeTextColor]
                
                let textSize: NSRect = badge.boundingRect(with: NSZeroSize, options: .usesFontLeading, attributes: attr as! [String : Any]?)
                if (textSize.size.width + CGFloat(lineWidth*4) >= rect.size.width) {
                    let maxWidth = size.width - CGFloat(lineWidth * 2)
                    let width = min(textSize.size.width + (lineWidth * 4), maxWidth)
                    
                    rect.origin.x -= (width - rect.size.width)
                    rect.size.width = width
                    
                    let newRadius = radius - (radius * (width - rect.size.width) / (maxWidth - rect.size.width))
                    radius = max(iconsize * 0.4, newRadius)
                    
                }
                
                let startPoint = CGPoint(x: CGFloat(rect.midX), y: CGFloat(rect.minY))
                let endPoint = CGPoint(x: CGFloat(rect.midX), y: CGFloat(rect.maxY))
                
                // Draw the ellipse
                let minx: CGFloat = rect.minX
                let midx: CGFloat = rect.midX
                let maxx: CGFloat = rect.maxX
                let miny: CGFloat = rect.minY
                let midy: CGFloat = rect.midY
                let maxy: CGFloat = rect.maxY
                
                // Draw the gradiant
                context.saveGState()
                context.beginPath()
                context.move(to: CGPoint(x: minx, y: midy))
                context.addArc(tangent1End: CGPoint(x: minx, y: miny), tangent2End: CGPoint(x: midx, y: miny), radius: CGFloat(radius))
                context.addArc(tangent1End: CGPoint(x: maxx, y: miny), tangent2End: CGPoint(x: maxx, y: midy), radius: CGFloat(radius))
                context.addArc(tangent1End: CGPoint(x: maxx, y: maxy), tangent2End: CGPoint(x: midx, y: maxy), radius: CGFloat(radius))
                context.addArc(tangent1End: CGPoint(x: minx, y: maxy), tangent2End: CGPoint(x: minx, y: midy), radius: CGFloat(radius))
                context.closePath()
                context.clip()
                context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
                
                
                // Draw the text
                let textBounds: NSRect = badge.boundingRect(with: NSZeroSize, options: .usesDeviceMetrics, attributes: attr as! [String : Any]?)
                rect.origin.x = rect.midX - (textSize.size.width * 0.5)
                rect.origin.x -= (textBounds.size.width - textSize.size.width) * 0.5
                rect.origin.y = rect.midY
                rect.origin.y -= textBounds.origin.y
                rect.origin.y -= ((textBounds.size.height - textSize.origin.y) * 0.5)
                rect.size.height = textSize.size.height
                rect.size.width = textSize.size.width
                badge.draw(in: rect, withAttributes: attr as! [String : Any]?)
                context.restoreGState()
                
                context.flush()
                context.restoreGState()
                newImage.addRepresentation(newRep!)
            }
            
        }
        
        return newImage


        
    }
            
            
}
