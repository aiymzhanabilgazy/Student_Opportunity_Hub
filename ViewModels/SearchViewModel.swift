import Foundation
import Combine

class SearchViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var selectedType: String = "All"
    @Published var selectedCountry: String = "All"
    @Published var results: [Opportunity] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private let allOpportunities =
        Array(repeating: SampleData.opportunities, count: 3).flatMap { $0 }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest3($searchText, $selectedType, $selectedCountry)
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] text, type, country in
                self?.filterOpportunities(query: text,
                                          type: type,
                                          country: country)
            }
            .store(in: &cancellables)
    }
    
    private func filterOpportunities(query: String,
                                     type: String,
                                     country: String) {
        
        var filtered = allOpportunities
        
        if !query.isEmpty {
            filtered = filtered.filter {
                $0.title.lowercased().contains(query.lowercased())
            }
        }
        
        if type != "All" {
            filtered = filtered.filter {
                $0.type == type
            }
        }
        
        if country != "All" {
            filtered = filtered.filter {
                $0.country == country
            }
        }
        
        results = filtered
    }
    
    // Available options
    var availableTypes: [String] {
        let types = Set(allOpportunities.map { $0.type })
        return ["All"] + types.sorted()
    }
    
    var availableCountries: [String] {
        let countries = Set(allOpportunities.map { $0.country })
        return ["All"] + countries.sorted()
    }
}

