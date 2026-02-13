import SwiftUI

struct SearchView: View {

    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 12) {

                    TextField("Search opportunities...", text: $viewModel.searchText)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    // Filters
                    HStack {
                        Picker("Type", selection: $viewModel.selectedType) {
                            ForEach(viewModel.availableTypes, id: \.self) { Text($0) }
                        }.pickerStyle(.menu)

                        Picker("Country", selection: $viewModel.selectedCountry) {
                            ForEach(viewModel.availableCountries, id: \.self) { Text($0) }
                        }.pickerStyle(.menu)
                    }
                    .padding(.horizontal)
                    .foregroundColor(.white)

                    Divider().background(Color.white)

                    content
                }
            }
            .navigationTitle("Search")
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {

        case .idle:
            Text("Start typing to search")
                .foregroundColor(.gray)
                .padding(.top, 30)

        case .loading:
            ProgressView("Searching...")
                .tint(.white)
                .padding(.top, 30)

        case .error(let msg):
            VStack(spacing: 12) {
                Text(msg).foregroundColor(.white)
                Button("Retry") {
                    Task { await viewModel.searchInitial(query: viewModel.searchText,
                                                         type: viewModel.selectedType,
                                                         country: viewModel.selectedCountry) }
                }
                .bold()
                .padding()
                .background(Color.accentBlue)
                .cornerRadius(12)
                .foregroundColor(.white)
            }
            .padding(.top, 30)

        case .empty:
            Text("No results found")
                .foregroundColor(.gray)
                .padding(.top, 30)

        default:
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.results) { opportunity in
                        NavigationLink {
                            DetailsView(opportunity: opportunity)
                        } label: {
                            OpportunityCardView(opportunity: opportunity)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            Task { await viewModel.loadMoreIfNeeded(currentItem: opportunity) }
                        }
                    }

                    if viewModel.state == .loadingMore {
                        ProgressView().tint(.white).padding()
                    }
                }
                .padding()
            }
        }
    }
}
