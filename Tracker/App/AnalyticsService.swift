//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Dinara on 18.03.2024.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func sctivate() {
        guard let configuration = YMMYandexMetricaConfiguration(
            apiKey: "5aa7540f-4dcd-40db-b7e0-25cf3ad17ecf") else {
                return
            }

            YMMYandexMetrica.activate(with: configuration)
        return
    }

    func report(
        event: Events,
        params : [AnyHashable : Any]
    ) {
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

enum Events: String, CaseIterable {
    case open = "open"
    case close = "close"
    case click = "click"
}

enum Items: String, CaseIterable {
    case add_track = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}
