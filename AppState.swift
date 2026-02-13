import Foundation
import SwiftUI

class AppState: ObservableObject {
    
    @Published var favorites: [Opportunity] = []
    @Published var appliedIds: Set<String> = []
    @Published var customOpportunities: [Opportunity] = []
    
    //favorites
    func toggleFavorite(_ opportunity: Opportunity) {
        if favorites.contains(where: { $0.id == opportunity.id }) {
            favorites.removeAll { $0.id == opportunity.id }
        } else {
            favorites.append(opportunity)
        }
    }
    
    func isFavorite(_ opportunity: Opportunity) -> Bool {
        favorites.contains { $0.id == opportunity.id }
    }
    
    //application status 
    func toggleApplied(_ opportunity: Opportunity) {
        if appliedIds.contains(opportunity.id) {
            appliedIds.remove(opportunity.id)
        } else {
            appliedIds.insert(opportunity.id)
        }
    }
    
    func isApplied(_ opportunity: Opportunity) -> Bool {
        appliedIds.contains(opportunity.id)
    }
    
    //create own opportunities
    func addOpportunity(
        title: String,
        description: String,
        country: String,
        deadline: Date,
        type: String
    ) {
        let newOpportunity = Opportunity(
            id: UUID().uuidString,
            title: title,
            description: description,
            country: country,
            deadline: deadline,
            type: type,
            tags: ["Custom"],
            imageURL: ""
        )
        
        customOpportunities.append(newOpportunity)
    }
}
