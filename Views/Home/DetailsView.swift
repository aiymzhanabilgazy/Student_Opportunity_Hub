import SwiftUI

struct DetailsView: View {
    
    let opportunity: Opportunity
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text(opportunity.title)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(opportunity.description)
                        .foregroundColor(.white)
                    
                    Text("Deadline: \(opportunity.daysLeft) days left")
                        .foregroundColor(.red)
                    
                    // Secondary screen navigation
                    NavigationLink {
                        CommentsView(opportunityId: opportunity.id)
                    } label: {
                        Text("View Comments")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentBlue)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    appState.toggleFavorite(opportunity)
                } label: {
                    Image(systemName:
                        appState.isFavorite(opportunity)
                        ? "star.fill"
                        : "star"
                    )
                    .foregroundColor(.yellow)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    appState.toggleApplied(opportunity)
                } label: {
                    Image(systemName:
                        appState.isApplied(opportunity)
                        ? "checkmark.circle.fill"
                        : "checkmark.circle"
                    )
                    .foregroundColor(
                        appState.isApplied(opportunity)
                        ? .green
                        : .gray
                    )
                }
            }
        }
    }
}
