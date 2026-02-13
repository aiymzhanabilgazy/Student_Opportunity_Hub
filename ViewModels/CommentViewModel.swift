import Foundation

class CommentsViewModel: ObservableObject {
    
    @Published var comments: [Comment] = []
    @Published var newCommentText: String = ""
    
    private let opportunityId: String
    
    init(opportunityId: String) {
        self.opportunityId = opportunityId
        loadMockComments()
    }
    
    private func loadMockComments() {
        comments = [
            Comment(
                id: UUID().uuidString,
                opportunityId: opportunityId,
                userName: "Aruzhan",
                text: "Is this open for 2nd year students?",
                createdAt: Date()
            ),
            Comment(
                id: UUID().uuidString,
                opportunityId: opportunityId,
                userName: "Dias",
                text: "Yes, I checked the requirements.",
                createdAt: Date()
            )
        ]
    }
    
    func addComment() {
        guard !newCommentText.isEmpty else { return }
        
        let comment = Comment(
            id: UUID().uuidString,
            opportunityId: opportunityId,
            userName: "You",
            text: newCommentText,
            createdAt: Date()
        )
        
        comments.append(comment)
        newCommentText = ""
    }
}
