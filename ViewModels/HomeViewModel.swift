import Foundation
import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    enum ViewState: Equatable {
        case idle
        case loading
        case loaded(isStale: Bool)
        case empty
        case error(String)
        case loadingMore
        case offlineShowingCache(String) // message
    }

    @Published var displayedOpportunities: [Opportunity] = []
    @Published var state: ViewState = .idle

    private let repo: OpportunitiesRepositoryProtocol

    private var currentPage = 1
    private var hasNextPage = true
    private var isRequestInFlight = false

    init(repo: OpportunitiesRepositoryProtocol = OpportunitiesRepository()) {
        self.repo = repo
    }

    func loadInitial() async {
        currentPage = 1
        hasNextPage = true
        displayedOpportunities = []

        // ✅ 1) показать кеш сразу
        do {
            let cached = try repo.loadCached()
            if !cached.isEmpty {
                displayedOpportunities = cached
                state = .loaded(isStale: CachePolicy.isStale)
            }
        } catch { /* кеш не критичен */ }

        // ✅ 2) затем попытаться обновить с сети
        await refresh()
    }

    func refresh() async {
        guard !isRequestInFlight else { return }
        isRequestInFlight = true
        state = displayedOpportunities.isEmpty ? .loading : state

        do {
            let result = try await repo.refreshFirstPage(query: nil)
            displayedOpportunities = result.items
            hasNextPage = result.hasNext
            state = displayedOpportunities.isEmpty ? .empty : .loaded(isStale: false)
        } catch {
            // ✅ если сеть упала, но кеш есть — показываем кеш и говорим offline
            if !displayedOpportunities.isEmpty {
                state = .offlineShowingCache(error.localizedDescription)
            } else {
                state = .error(error.localizedDescription)
            }
        }

        isRequestInFlight = false
    }

    func loadNextPage() async {
        guard hasNextPage, !isRequestInFlight else { return }
        isRequestInFlight = true
        state = .loadingMore
        currentPage += 1

        do {
            let result = try await repo.fetchPage(page: currentPage, query: nil)
            displayedOpportunities.append(contentsOf: result.items)
            hasNextPage = result.hasNext
            state = .loaded(isStale: false)
        } catch {
            // при ошибке просто не падаем
            state = .offlineShowingCache(error.localizedDescription)
            currentPage -= 1
        }

        isRequestInFlight = false
    }

    var canLoadMore: Bool { hasNextPage }
}
