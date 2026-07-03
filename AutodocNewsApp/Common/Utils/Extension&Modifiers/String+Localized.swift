//
//  String+Localized.swift
//  AutodocNewsApp
//
//  Created by A Ch on 03.07.2026.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
