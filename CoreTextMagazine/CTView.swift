//
//  CTView.swift
//  CoreTextMagazine
//
//  Created by Ihor Kandaurov on 8/5/18.
//  Copyright © 2018 Ihor Kandaurov. All rights reserved.
//

import UIKit
import CoreText

class CTView: UIScrollView {
    
    //MARK: - Properties
    var imageIndex: Int!


    func buildFrames(withAttrString attrString: NSAttributedString,
                     andImages images: [[String: Any]]) {
        
        imageIndex = 0
        
        isPagingEnabled = true
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
        
        var pageView = UIView()
        var textPos = 0
        var columnIndex: CGFloat = 0
        var pageIndex: CGFloat = 0
        let settings = CTSettings()
        
        while textPos < attrString.length {

            if columnIndex.truncatingRemainder(dividingBy: settings.columnsPerPage) == 0 {
                columnIndex = 0
                pageView = UIView(frame: settings.pageRect.offsetBy(dx: pageIndex * bounds.width, dy: 0))
                addSubview(pageView)
                
                pageIndex += 1
            }
            
            let columnXOrigin = pageView.frame.size.width / settings.columnsPerPage
            
            let columnOffset = columnIndex * columnXOrigin
            
            let columnFrame = settings.columnRect.offsetBy(dx: columnOffset, dy: 0)
            
            let path = CGMutablePath()
            
            path.addRect(CGRect(origin: .zero, size: columnFrame.size))
            
            let ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, nil)
            
            let column = CTColumnView(frame: columnFrame, ctframe: ctframe)
            pageView.addSubview(column)
            
            if images.count > imageIndex {
                attachImagesWithFrame(images, ctframe: ctframe, margin: settings.margin, columnView: column)
            }
            
            let frameRange = CTFrameGetVisibleStringRange(ctframe)
            
            textPos += frameRange.length
            columnIndex += 1
        }
        contentSize = CGSize(width: CGFloat(pageIndex) * bounds.size.width,
                             height: bounds.size.height)
    }
    
    func attachImagesWithFrame(_ images: [[String: Any]],
                               ctframe: CTFrame,
                               margin: CGFloat,
                               columnView: CTColumnView) {
        
        let lines = CTFrameGetLines(ctframe) as NSArray
        
        var origins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), &origins)
        
        var nextImage = images[imageIndex]
        guard var imgLocation = nextImage["location"] as? Int else {
            return
        }
        
        for lineIndex in 0..<lines.count {
            let line = lines[lineIndex] as! CTLine
            
            if let glyphRuns = CTLineGetGlyphRuns(line) as? [CTRun],
                let imageFilename = nextImage["filename"] as? String,
                let img = UIImage(named: imageFilename)  {
                for run in glyphRuns {
                    
                    let runRange = CTRunGetStringRange(run)
                    if runRange.location > imgLocation || runRange.location + runRange.length <= imgLocation {
                        continue
                    }
                    
                    var imgBounds: CGRect = .zero
                    var ascent: CGFloat = 0
                    imgBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, nil, nil))
                    imgBounds.size.height = ascent
                    
                    let xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                    imgBounds.origin.x = origins[lineIndex].x + xOffset
                    imgBounds.origin.y = origins[lineIndex].y
                    
                    columnView.images += [(image: img, frame: imgBounds)]
                    
                    imageIndex! += 1
                    if imageIndex < images.count {
                        nextImage = images[imageIndex]
                        imgLocation = (nextImage["location"] as AnyObject).intValue
                    }
                }
            }
        }
    }

}
