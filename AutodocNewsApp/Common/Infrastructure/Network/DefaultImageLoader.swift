//
//  DefaultImageLoader.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import UIKit

/// Default ImageLoader backed by URLSession with an in-memory NSCache.
actor DefaultImageLoader: ImageLoader {

    private let cache = NSCache<NSString, UIImage>()
    private var inFlight: [String: Task<UIImage?, Never>] = [:]

    init() {
        cache.countLimit = 200
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }

    /// Returns a cached image or downloads, decodes, and caches it.
    /// Concurrent calls for the same URL share a single download task.
    /// - Parameter urlString: Remote image URL string.
    /// - Returns: Loaded image, or `nil` on failure.
    func loadImage(from urlString: String) async -> UIImage? {
        let key = urlString as NSString

        if let cached = cache.object(forKey: key) {
            return cached
        }

        if let existing = inFlight[urlString] {
            return await existing.value
        }

        let task = Task<UIImage?, Never> {
            guard let url = URL(string: urlString) else { return nil }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                guard let image = UIImage(data: data) else { return nil }
                
                cache.setObject(image, forKey: key, cost: data.count)
                return image
            } catch {
                return nil
            }
        }

        inFlight[urlString] = task
        let image = await task.value
        inFlight.removeValue(forKey: urlString)
        return image
    }
}
