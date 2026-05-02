//
//  RemoteConfigService.swift
//  SwiftSampleApp
//

import Foundation
import FirebaseRemoteConfig

final class RemoteConfigService {

    static let shared = RemoteConfigService()

    private let remoteConfig = RemoteConfig.remoteConfig()

    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([
            "swiper_enabled":    true as NSObject,
            "max_post_length":   300 as NSObject,
            "min_app_version":   "1.0.0" as NSObject
        ])
    }

    func fetchAndActivate(completion: (() -> Void)? = nil) {
        remoteConfig.fetchAndActivate { _, _ in
            completion?()
        }
    }

    var swiperEnabled: Bool {
        remoteConfig.configValue(forKey: "swiper_enabled").boolValue
    }

    var maxPostLength: Int {
        Int(remoteConfig.configValue(forKey: "max_post_length").numberValue)
    }

    var minimumAppVersion: String {
        remoteConfig.configValue(forKey: "min_app_version").stringValue
    }
}
