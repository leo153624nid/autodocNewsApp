//
//  NewsWebViewController.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import UIKit
import WebKit

final class NewsWebViewController: UIViewController {

    private let url: URL
    private var webView: WKWebView!
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private var progressObservation: NSKeyValueObservation?

    init(url: URL, title: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupWebView()
        setupProgressView()
        webView.load(URLRequest(url: url))
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    // MARK: - Setup

    private func setupWebView() {
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = .systemBlue
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        progressObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] webView, _ in
            DispatchQueue.main.async {
                let progress = Float(webView.estimatedProgress)
                self?.progressView.setProgress(progress, animated: true)
                self?.progressView.isHidden = progress >= 1.0
            }
        }
    }

    deinit {
        progressObservation?.invalidate()
    }
}
