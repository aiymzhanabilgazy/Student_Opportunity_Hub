import SwiftUI
import Kingfisher

struct OpportunityCardView: View {

    let opportunity: Opportunity

    // ✅ 100% всегда будет URL
    private var imageToShow: URL? {
        let raw = opportunity.imageURL.trimmingCharacters(in: .whitespacesAndNewlines)

        if !raw.isEmpty, let url = URL(string: raw) {
            return url
        }

        // fallback: генерим картинку по названию (всегда работает)
        let safe = opportunity.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Opportunity"
        return URL(string: "https://ui-avatars.com/api/?name=\(safe)&background=0b1f3b&color=ffffff&size=512")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            KFImage(imageToShow)
                .resizable()
                .cancelOnDisappear(true)
                .onFailure { error in
                    // ✅ полезно для дебага в консоли
                    print("❌ Image load failed for:", opportunity.imageURL, "error:", error)
                }
                .placeholder {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cardBackground.opacity(0.6))
                        .frame(height: 140)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .fade(duration: 0.2)
                .aspectRatio(16/9, contentMode: .fill)
                .frame(height: 140)
                .clipped()
                .cornerRadius(12)

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
            return Text("🔥 Urgent").foregroundColor(.red)
        case .warning:
            return Text("⚠️ Soon").foregroundColor(.yellow)
        case .normal:
            return Text("✅ Normal").foregroundColor(.green)
        }
    }
}
