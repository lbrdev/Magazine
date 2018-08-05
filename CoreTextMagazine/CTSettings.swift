//
//  CTSettings.swift
//  CoreTextMagazine
//
//  Created by Ihor Kandaurov on 8/5/18.
//  Copyright © 2018 Ihor Kandaurov. All rights reserved.
//

import UIKit
import Foundation

class CTSettings {
    
    // MARK: - Properties
    let margin: CGFloat = 20
    var columnsPerPage: CGFloat!
    var pageRect: CGRect!
    var columnRect: CGRect!
    
    // MARK: - Initializers
    init() {
  
        columnsPerPage = UIDevice.current.userInterfaceIdiom == .phone ? 1 : 2
   
        pageRect = UIScreen.main.bounds.insetBy(dx: margin, dy: margin)
    
        columnRect = CGRect(x: 0,
                            y: 0,
                            width: pageRect.width / columnsPerPage,
                            height: pageRect.height).insetBy(dx: margin, dy: margin)
    }
}
