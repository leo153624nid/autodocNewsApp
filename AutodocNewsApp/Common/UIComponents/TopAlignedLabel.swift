//
//  TopAlignedLabel.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import UIKit

/// UILabel subclass that always renders text top-aligned within its bounds.
final class TopAlignedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        let fittingSize = sizeThatFits(rect.size)
        let topRect = CGRect(
            origin: rect.origin,
            size: CGSize(width: rect.width, height: fittingSize.height)
        )
        super.drawText(in: topRect)
    }
    
}
