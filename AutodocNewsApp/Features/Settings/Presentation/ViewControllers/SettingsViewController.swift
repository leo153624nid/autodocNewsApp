//
//  SettingsViewController.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import UIKit

final class SettingsViewController: UIViewController {

    private let viewModel: SettingsViewModel

    // MARK: - Initialization

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "screen.settings.title".localized
        view.backgroundColor = .systemGroupedBackground
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
