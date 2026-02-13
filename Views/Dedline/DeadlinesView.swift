import SwiftUI

struct DeadlinesView: View {
    
    @EnvironmentObject var appState: AppState
    @State private var showAppliedOnly = false
    
    var trackedOpportunities: [Opportunity] {
        let all = SampleData.opportunities   // временно
        
        let filtered = all.filter {
            appState.isFavorite($0) || appState.isApplied($0)
        }
        
        return filtered.sorted {
            $0.daysLeft < $1.daysLeft
        }
    }

    
    var filteredOpportunities: [Opportunity] {
        if showAppliedOnly {
            return trackedOpportunities.filter {
                appState.isApplied($0)
            }
        } else {
            return trackedOpportunities
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack {
                    
                    // 🔥 Toggle filtering
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
    }
}
