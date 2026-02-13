import Foundation

struct Comment: Identifiable, Codable, Equatable {
    let id: String
    let opportunityId: String
    let authorUid: String
    let userName: String
    let text: String
    let createdAt: TimeInterval // unix seconds
    
    var createdDate: Date { Date(timeIntervalSince1970: createdAt) }
}
