//
//  AlertItem.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import SwiftUI

/// Alert data
struct AlertItem { // TODO: delete ?
    /// Alert title
    let title: String
    /// Alert message
    let message: String
    /// Alert actions
    let actions: [AlertAction]
    /// Alert style
    var style: AlertStyle = .system
}

/// Action data for alert
struct AlertAction {
    /// Action button title
    let title: String
    /// Action button role
    var role: ButtonRole? = .none
    /// Action of button
    let action: () -> Void
}

/// Alert style
enum AlertStyle: Equatable {
    case system
    case designed(DesignedAlertType = .base)
}

/// Designed alert type
enum DesignedAlertType {
    /// Base
    case base
}

// MARK: - Ready alerts
extension AlertItem {
    /// Alert item for news feed error
    static func newsErrorMessageAlertItem(with message: String,
                                          action: @escaping () -> Void) -> AlertItem {  // TODO: localize
        AlertItem(title: "Error",
                  message: message,
                  actions: [
                    AlertAction(title: "Cancel",
                                action: {}),
                    AlertAction(title: "Retry",
                                role: .cancel,
                                action: { action() }),
                  ])
    }
    
}
