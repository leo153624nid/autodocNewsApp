//
//  DefaultImageLoader.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import UIKit

final class DefaultImageLoader: ImageLoader {

    private let cache = NSCache<NSString, UIImage>()

    init() {
        cache.countLimit = 200
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }

    func loadImage(from urlString: String) async -> UIImage? {
        let key = urlString as NSString

        if let cached = cache.object(forKey: key) {
            return cached
        }

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
}
