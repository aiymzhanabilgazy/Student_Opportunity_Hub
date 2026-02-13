import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {

                    banner   // 👈 ВОТ СЮДА

                    ForEach(viewModel.displayedOpportunities) { opportunity in
                        NavigationLink {
                            DetailsView(opportunity: opportunity)
                        } label: {
                            OpportunityCardView(opportunity: opportunity)
                        }
                        .buttonStyle(.plain)
                    }

                    if viewModel.canLoadMore {
                        Button {
                            Task { await viewModel.loadNextPage() }
                        } label: {
                            Text("Show More")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .background(Color.accentBlue)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .background(Color.appBackground)
            .navigationTitle("Opportunities")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private var banner: some View {
        switch viewModel.state {
        case .loaded(let isStale) where isStale:
            Text("Cached data (may be outdated). Pull to refresh.")
                .font(.caption)
                .foregroundColor(.yellow)
                .padding(.vertical, 6)

        case .offlineShowingCache(let msg):
            Text("Offline. Showing cached data. (\(msg))")
                .font(.caption)
                .foregroundColor(.yellow)
                .padding(.vertical, 6)

        default:
            EmptyView()
        }
    }
}
