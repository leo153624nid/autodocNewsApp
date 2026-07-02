//
//  SettingsViewModel.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Combine
import Foundation

enum SettingsViewAction {}

final class SettingsViewModel: ViewModel {

    unowned let coordinator: any SettingsTabCoordinatorProtocol

    init(coordinator: any SettingsTabCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func perform(action: SettingsViewAction) {}
}
