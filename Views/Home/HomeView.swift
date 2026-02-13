import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    
                    ForEach(viewModel.displayedOpportunities) { opportunity in
                        NavigationLink {
                            DetailsView(opportunity: opportunity)
                        } label: {
                            OpportunityCardView(opportunity: opportunity)
                        }
                    }
                    
                    if viewModel.canLoadMore {
                        Button {
                            viewModel.loadNextPage()
                        } label: {
                            Text("Show More")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentBlue)
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Opportunities")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(.dark)
    }
}
