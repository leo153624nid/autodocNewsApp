//
//  ImageLoader.swift
//  AutodocNewsApp
//
//  Created by A Ch on 03.07.2026.
//

import UIKit

protocol ImageLoader {
    
    func loadImage(from urlString: String) async -> UIImage?
    
}
