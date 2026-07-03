//
//  String+Localized.swift
//  AutodocNewsApp
//
//  Created by A Ch on 03.07.2026.
//

import Foundation

extension String {
    /// Looks up the string as a key in `Localizable.strings` and returns the localized value.
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
