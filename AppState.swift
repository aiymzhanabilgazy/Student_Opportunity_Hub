import Foundation
import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {

    @Published var favorites: [Opportunity] = []
    @Published var appliedIds: Set<String> = []
    @Published var customOpportunities: [Opportunity] = []

    private let local: OpportunityLocalStoreProtocol

    init(local: OpportunityLocalStoreProtocol = OpportunityLocalStore()) {
        self.local = local
        loadCustomFromCache()
    }

    // MARK: - favorites

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

    // MARK: - applied

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

    // MARK: - custom opportunities (persisted)

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
            imageURL: "" // можешь тоже дать URL, если хочешь
        )

        // 1) сразу в UI
        customOpportunities.insert(newOpportunity, at: 0)

        // 2) ✅ сохранить в CoreData как source="custom"
        do {
            try local.upsert([newOpportunity], source: "custom")
        } catch {
            print("❌ Failed to save custom opportunity:", error.localizedDescription)
        }
    }

    private func loadCustomFromCache() {
        do {
            customOpportunities = try local.fetchCustom()
        } catch {
            customOpportunities = []
            print("❌ Failed to load custom opportunities:", error.localizedDescription)
        }
    }
}
