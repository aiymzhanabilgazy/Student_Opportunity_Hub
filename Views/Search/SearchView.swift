import SwiftUI

struct SearchView: View {
    
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    
                    // 🔍 Search field
                    TextField("Search opportunities...", text: $viewModel.searchText)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // 🎯 Filters
                    HStack {
                        
                        Picker("Type", selection: $viewModel.selectedType) {
                            ForEach(viewModel.availableTypes, id: \.self) { type in
                                Text(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Picker("Country", selection: $viewModel.selectedCountry) {
                            ForEach(viewModel.availableCountries, id: \.self) { country in
                                Text(country)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding(.horizontal)
                    .foregroundColor(.white)
                    
                    Divider().background(Color.white)
                    
                    // 📦 Results
                    if viewModel.results.isEmpty {
                        Text("No results found")
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.results) { opportunity in
                                NavigationLink {
                                    DetailsView(opportunity: opportunity)
                                } label: {
                                    OpportunityCardView(opportunity: opportunity)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Search")
        }
        .preferredColorScheme(.dark)
    }
}
