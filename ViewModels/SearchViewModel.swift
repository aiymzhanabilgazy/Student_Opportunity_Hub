import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {

    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
        case loadingMore
    }

    @Published var searchText: String = ""
    @Published var selectedType: String = "All"
    @Published var selectedCountry: String = "All"
    @Published var results: [Opportunity] = []
    @Published var state: ViewState = .idle

    private let repo: OpportunitiesRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    private var currentPage = 1
    private var hasNextPage = true
    private var isRequestInFlight = false

    init(repo: OpportunitiesRepositoryProtocol = OpportunitiesRepository()) {
        self.repo = repo
        setupBindings()
    }

    private func setupBindings() {
        Publishers.CombineLatest3($searchText, $selectedType, $selectedCountry)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates(by: { $0.0 == $1.0 && $0.1 == $1.1 && $0.2 == $1.2 })
            .sink { [weak self] text, type, country in
                guard let self else { return }
                Task { await self.searchInitial(query: text, type: type, country: country) }
            }
            .store(in: &cancellables)
    }

    func searchInitial(query: String, type: String, country: String) async {
        currentPage = 1
        hasNextPage = true
        results = []
        await fetch(query: query, type: type, country: country, isInitial: true)
    }

    func loadMoreIfNeeded(currentItem: Opportunity) async {
        guard let last = results.last else { return }
        guard last.id == currentItem.id else { return }
        guard hasNextPage, !isRequestInFlight else { return }

        currentPage += 1
        await fetch(query: searchText, type: selectedType, country: selectedCountry, isInitial: false)
    }

    var canLoadMore: Bool { hasNextPage }

    private func fetch(query: String, type: String, country: String, isInitial: Bool) async {
        guard !isRequestInFlight else { return }
        isRequestInFlight = true

        state = isInitial ? .loading : .loadingMore

        do {
            let result = try await repo.fetchPage(page: currentPage, query: query.isEmpty ? nil : query)

            // фильтры Type/Country можно оставить как client-side, потому что API не даёт прямых фильтров
            var items = result.items

            if type != "All" {
                items = items.filter { $0.type == type }
            }
            if country != "All" {
                items = items.filter { $0.country.localizedCaseInsensitiveContains(country) }
            }

            if isInitial {
                results = items
            } else {
                results.append(contentsOf: items)
            }

            hasNextPage = result.hasNext

            state = results.isEmpty ? .empty : .loaded

        } catch {
            state = .error(error.localizedDescription)
        }

        isRequestInFlight = false
    }

    // Options для picker-ов теперь строим из results (или оставь статикой)
    var availableTypes: [String] {
        let types = Set(results.map { $0.type })
        return ["All"] + types.sorted()
    }

    var availableCountries: [String] {
        let countries = Set(results.map { $0.country })
        return ["All"] + countries.sorted()
    }
}
