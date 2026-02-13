import Foundation

struct Opportunity: Identifiable {
    let id: String
    let title: String
    let description: String
    let country: String
    let deadline: Date
    let type: String
    let tags: [String]
    let imageURL: String
}

