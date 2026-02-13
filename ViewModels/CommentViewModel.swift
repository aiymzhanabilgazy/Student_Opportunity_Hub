import Foundation
import FirebaseAuth
import Combine

@MainActor
final class CommentsViewModel: ObservableObject {

    @Published var comments: [Comment] = []
    @Published var newCommentText: String = ""
    @Published var errorMessage: String = ""

    private let opportunityId: String
    private let service: CommentsServiceProtocol

    init(opportunityId: String,
        service: CommentsServiceProtocol = CommentsService()) {
        self.opportunityId = opportunityId
        self.service = service
        print("👀 Comments for oppId:", opportunityId)


        startListening()
    }

    deinit {
        service.stopObserving(opportunityId: opportunityId)
    }

    private func startListening() {
        service.observeComments(opportunityId: opportunityId) { [weak self] items in
            self?.comments = items
        }
    }

    func addComment() {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        guard let user = Auth.auth().currentUser else {
            errorMessage = "You must be logged in to comment."
            return
        }

        let comment = Comment(
            id: "", // id создаст Firebase
            opportunityId: opportunityId,
            authorUid: user.uid,
            userName: user.email ?? "User",
            text: newCommentText,
            createdAt: Date().timeIntervalSince1970
        )

        let textToSend = newCommentText
        newCommentText = ""

        Task {
            do {
                try await service.addComment(opportunityId: opportunityId, comment: comment)
            } catch {
                // вернём текст обратно, если не отправилось
                newCommentText = textToSend
                errorMessage = error.localizedDescription
            }
        }
    }

    func deleteComment(_ comment: Comment) {
        guard let user = Auth.auth().currentUser else { return }
        guard comment.authorUid == user.uid else {
            errorMessage = "You can delete only your own comment."
            return
        }

        Task {
            do {
                try await service.deleteComment(opportunityId: opportunityId, commentId: comment.id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func updateComment(_ comment: Comment, newText: String) {
        guard let user = Auth.auth().currentUser else { return }
        guard comment.authorUid == user.uid else {
            errorMessage = "You can edit only your own comment."
            return
        }

        Task {
            do {
                try await service.updateComment(opportunityId: opportunityId, commentId: comment.id, newText: newText)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func canEdit(_ comment: Comment) -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        return comment.authorUid == user.uid
    }
}
