import SwiftUI

struct DeadlinesView: View {

    @EnvironmentObject var appState: AppState
    @State private var showAppliedOnly = false
    @State private var cached: [Opportunity] = []

    private let repo: OpportunitiesRepositoryProtocol = OpportunitiesRepository()

    var trackedOpportunities: [Opportunity] {
        let all = cached + appState.customOpportunities

        let filtered = all.filter { opp in
            // ✅ Created всегда показываем
            if appState.customOpportunities.contains(where: { $0.id == opp.id }) {
                return true
            }
            // ✅ Остальные — только saved/applied
            return appState.isFavorite(opp) || appState.isApplied(opp)
        }

        return filtered.sorted { $0.daysLeft < $1.daysLeft }
    }


    var filteredOpportunities: [Opportunity] {
        showAppliedOnly ? trackedOpportunities.filter { appState.isApplied($0) } : trackedOpportunities
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack {
                    Toggle("Show Applied Only", isOn: $showAppliedOnly)
                        .padding()
                        .foregroundColor(.white)

                    if filteredOpportunities.isEmpty {
                        Text("No saved opportunities yet")
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredOpportunities) { opportunity in
                                    NavigationLink {
                                        DetailsView(opportunity: opportunity)
                                    } label: {
                                        OpportunityCardView(opportunity: opportunity)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("My Deadlines")
        }
        .preferredColorScheme(.dark)
        .task { loadCache() }
    }

    private func loadCache() {
        do { cached = try repo.loadCached() }
        catch { cached = [] }
    }
}
