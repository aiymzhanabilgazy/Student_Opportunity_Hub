import SwiftUI

struct OpportunityCardView: View {
    
    let opportunity: Opportunity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text(opportunity.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text("\(opportunity.country)  \(opportunity.type)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                priorityView
                Spacer()
                Text("\(opportunity.daysLeft) days left")
                    .foregroundColor(.white)
                    .font(.caption)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(opportunity.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(6)
                            .background(Color.accentBlue.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var priorityView: some View {
        switch opportunity.priority {
        case .critical:
            return Text("🔥 Urgent")
                .foregroundColor(.red)
        case .warning:
            return Text("⚠️ Soon")
                .foregroundColor(.yellow)
        case .normal:
            return Text("✅ Normal")
                .foregroundColor(.green)
        }
    }
}
