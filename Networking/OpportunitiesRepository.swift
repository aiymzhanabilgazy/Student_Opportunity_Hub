import Foundation

protocol OpportunitiesRepositoryProtocol {
    func loadCached() throws -> [Opportunity]
    func refreshFirstPage(query: String?) async throws -> (items: [Opportunity], hasNext: Bool)
    func fetchPage(page: Int, query: String?) async throws -> (items: [Opportunity], hasNext: Bool)
}

final class OpportunitiesRepository: OpportunitiesRepositoryProtocol {

    private let api: OpportunitiesAPIProtocol
    private let local: OpportunityLocalStoreProtocol

    init(
        api: OpportunitiesAPIProtocol = OpportunitiesAPI(),
        local: OpportunityLocalStoreProtocol = OpportunityLocalStore()
    ) {
        self.api = api
        self.local = local
    }

    func loadCached() throws -> [Opportunity] {
        try local.fetchAll(limit: nil)
    }

    func refreshFirstPage(query: String?) async throws -> (items: [Opportunity], hasNext: Bool) {
        // 1) fetch remote page 1
        let remote = try await api.fetchJobs(page: 1, query: query)

        // 2) если это “главная лента” без query — можно очистить старый remote кеш и записать заново
        //    для search лучше НЕ чистить, просто upsert (поэтому чистим только когда query == nil)
        if query == nil {
            try? local.deleteAllRemote()
        }

        // 3) cache
        try local.upsert(remote.items, source: "remote")
        CachePolicy.lastRefreshAt = Date()

        return remote
    }

    func fetchPage(page: Int, query: String?) async throws -> (items: [Opportunity], hasNext: Bool) {
        let remote = try await api.fetchJobs(page: page, query: query)
        try local.upsert(remote.items, source: "remote")
        return remote
    }
}
