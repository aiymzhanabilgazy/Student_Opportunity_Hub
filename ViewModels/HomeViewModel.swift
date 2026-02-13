import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published var displayedOpportunities: [Opportunity] = []
    
    private var allOpportunities: [Opportunity] =
        Array(repeating: SampleData.opportunities, count: 6).flatMap { $0 }

    
    private var currentPage = 0
    private let pageSize = 3  // для теста поставим 2
    init() {
        loadNextPage()
    }
    
    func loadNextPage() {
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, allOpportunities.count)
        
        guard startIndex < endIndex else { return }
        
        let nextItems = Array(allOpportunities[startIndex..<endIndex])
        displayedOpportunities.append(contentsOf: nextItems)
        
        currentPage += 1
    }
    
    var canLoadMore: Bool {
        displayedOpportunities.count < allOpportunities.count
    }
}
