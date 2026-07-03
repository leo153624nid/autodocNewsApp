//
//  NewsCell.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import UIKit

/// Collection view cell that shows a news article thumbnail, title, and date.
final class NewsCell: UICollectionViewCell {

    /// Reuse identifier for dequeuing.
    static let reuseIdentifier = "NewsCell"

    @InjectedLazy private var imageLoader: ImageLoader

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

    private let imageSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    private let placeholderIconView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "imagePlaceholder"))
        view.contentMode = .scaleAspectFit
        view.tintColor = .systemGray3
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
        contentView.addSubview(placeholderIconView)
        contentView.addSubview(imageSpinner)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),

            placeholderIconView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderIconView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            placeholderIconView.widthAnchor.constraint(equalToConstant: 96),
            placeholderIconView.heightAnchor.constraint(equalToConstant: 96),

            imageSpinner.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            imageSpinner.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

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

    /// Populates the cell with article data and starts the image load.
    /// - Parameter item: News article to display.
    func configure(with item: NewsItem) {
        titleLabel.text = item.title
        dateLabel.text = item.publishedDate?.toSectionHeaderString() ?? "news.cell.no_date".localized

        // Cancel any in-flight image load before starting a new one
        imageTask?.cancel()
        imageView.image = nil
        imageSpinner.stopAnimating()

        let urlString = item.titleImageUrl ?? ""
        currentUrlString = urlString

        guard !urlString.isEmpty else {
            placeholderIconView.isHidden = false
            return
        }

        placeholderIconView.isHidden = true
        imageSpinner.startAnimating()
        imageTask = Task { [weak self] in
            guard let self else { return }
            
            let image = await imageLoader.loadImage(from: urlString)

            guard !Task.isCancelled,
                  currentUrlString == urlString else { return }

            await MainActor.run {
                self.imageSpinner.stopAnimating()
                if let image {
                    self.imageView.image = image
                } else {
                    self.placeholderIconView.isHidden = false
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        currentUrlString = nil
        imageView.image = nil
        imageSpinner.stopAnimating()
        placeholderIconView.isHidden = true
        titleLabel.text = nil
        dateLabel.text = nil
    }
    
}
