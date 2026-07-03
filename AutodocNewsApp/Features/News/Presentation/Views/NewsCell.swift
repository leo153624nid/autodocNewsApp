//
//  NewsCell.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import UIKit

final class NewsCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NewsCell"

    private var currentUrlString: String?
    private var imageTask: Task<Void, Never>?

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: TopAlignedLabel = {
        let label = TopAlignedLabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
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
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with item: NewsItem) {
        titleLabel.text = item.title
        dateLabel.text = item.publishedDate?.toSectionHeaderString() ?? "news.cell.no_date".localized

        // Cancel any in-flight image load before starting a new one
        imageTask?.cancel()
        imageView.image = nil

        let urlString = item.titleImageUrl ?? ""
        currentUrlString = urlString

        guard !urlString.isEmpty else { return }

        imageTask = Task { [weak self] in
            let image = await ImageLoader.shared.loadImage(from: urlString)
            
            guard !Task.isCancelled,
                  self?.currentUrlString == urlString else { return }
            
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
        dateLabel.text = nil
    }
    
}
