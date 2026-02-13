import Foundation

struct Comment: Identifiable {
    let id: String
    let opportunityId: String
    let userName: String
    let text: String
    let createdAt: Date
}
