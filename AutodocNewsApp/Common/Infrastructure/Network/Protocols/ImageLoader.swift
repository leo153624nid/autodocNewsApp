//
//  ImageLoader.swift
//  AutodocNewsApp
//
//  Created by A Ch on 03.07.2026.
//

import UIKit

/// Contract for asynchronous image loading with caching.
protocol ImageLoader {
    
    /// Downloads and caches an image.
    /// - Parameter urlString: Remote image URL string.
    /// - Returns: Loaded image, or `nil` on failure or invalid URL.
    func loadImage(from urlString: String) async -> UIImage?
    
}
