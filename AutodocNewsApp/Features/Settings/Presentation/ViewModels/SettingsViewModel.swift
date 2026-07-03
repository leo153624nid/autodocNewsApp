//
//  SettingsViewModel.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Combine
import Foundation

/// Actions from the Settings view.
enum SettingsViewAction {}

/// ViewModel for the Settings screen.
@MainActor
final class SettingsViewModel: ViewModel {

    /// Coordinator that handles Settings navigation.
    unowned let coordinator: any SettingsTabCoordinatorProtocol

    /// Creates the view model.
    /// - Parameter coordinator: Settings tab coordinator.
    init(coordinator: any SettingsTabCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    /// Handles a Settings view action.
    /// - Parameter action: Action triggered by the view.
    func perform(action: SettingsViewAction) {}
}
