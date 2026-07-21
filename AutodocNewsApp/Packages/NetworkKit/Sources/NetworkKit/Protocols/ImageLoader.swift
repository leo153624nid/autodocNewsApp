import UIKit

/// Contract for asynchronous image loading with caching.
public protocol ImageLoader {
    /// Downloads and caches an image.
    /// - Parameter urlString: Remote image URL string.
    /// - Returns: Loaded image, or `nil` on failure or invalid URL.
    func loadImage(from urlString: String) async -> UIImage?
}
