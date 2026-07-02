//
//  NewsCell.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import UIKit

final class NewsCell: UICollectionViewCell {
    static let reuseIdentifier = "NewsCell"

    private var imageTask: Task<Void, Never>?
    private var currentUrlString: String?

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with item: NewsItem) {
        titleLabel.text = item.title

        // Cancel any in-flight image load before starting a new one
        imageTask?.cancel()
        imageView.image = nil

        let urlString = item.titleImageUrl ?? ""
        currentUrlString = urlString

        guard !urlString.isEmpty else { return }

        imageTask = Task { [weak self] in
            let image = await ImageLoader.shared.loadImage(from: urlString)
            // Guard against cell reuse: only apply if this cell still shows the same URL
            guard !Task.isCancelled, self?.currentUrlString == urlString else { return }
            await MainActor.run {
                self?.imageView.image = image
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        currentUrlString = nil
        imageView.image = nil
        titleLabel.text = nil
    }
}
