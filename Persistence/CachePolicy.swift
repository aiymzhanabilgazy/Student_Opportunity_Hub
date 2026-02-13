import Foundation

enum CachePolicy {
    static let lastRefreshKey = "opportunities_last_refresh"

    static var lastRefreshAt: Date? {
        get { UserDefaults.standard.object(forKey: lastRefreshKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastRefreshKey) }
    }

    static var isStale: Bool {
        guard let last = lastRefreshAt else { return true }
        return Date().timeIntervalSince(last) > 60 * 60 * 24 // 24h
    }
}
