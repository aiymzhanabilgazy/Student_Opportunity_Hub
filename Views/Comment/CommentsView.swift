import SwiftUI

struct CommentsView: View {

    @StateObject private var viewModel: CommentsViewModel

    // Edit UI state
    @State private var editingComment: Comment? = nil
    @State private var editingText: String = ""

    init(opportunityId: String) {
        _viewModel = StateObject(wrappedValue: CommentsViewModel(opportunityId: opportunityId))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // Error banner
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                        .padding(.horizontal)
                }

                // List
                ScrollView {
                    LazyVStack(spacing: 16) {

                        if viewModel.comments.isEmpty {
                            Text("No comments yet")
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                        } else {
                            ForEach(viewModel.comments) { comment in
                                commentCard(comment)
                            }
                        }
                    }
                    .padding()
                }

                Divider().background(Color.white.opacity(0.4))

                // Composer
                composer
                    .padding()
            }
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingComment) { comment in
            editSheet(comment: comment)
        }
    }

    // MARK: - UI Parts

    private func commentCard(_ comment: Comment) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack {
                Text(comment.userName)
                    .font(.headline)
                    .foregroundColor(.white)

                if viewModel.canEdit(comment) {
                    Text("(You)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                // ✅ ЯВНАЯ кнопка вместо "спрятано в long press"
                if viewModel.canEdit(comment) {
                    Menu {
                        Button("Edit") {
                            editingComment = comment
                            editingText = comment.text
                        }

                        Button("Delete", role: .destructive) {
                            viewModel.deleteComment(comment)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 6)
                    }
                }
            }

            Text(comment.text)
                .foregroundColor(.white)

            Text(comment.createdDate.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }

    private var composer: some View {
        HStack(spacing: 12) {
            TextField("Write a comment...", text: $viewModel.newCommentText)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                .foregroundColor(.white)

            Button("Send") {
                viewModel.addComment()
            }
            .foregroundColor(.accentBlue)
            .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
        }
    }

    private func editSheet(comment: Comment) -> some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 16) {

                    TextEditor(text: $editingText)
                        .padding()
                        .frame(height: 180)
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .foregroundColor(.white)

                    Button("Save") {
                        let trimmed = editingText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        viewModel.updateComment(comment, newText: trimmed)
                        editingComment = nil
                    }
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentBlue)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .disabled(editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button("Cancel") {
                        editingComment = nil
                    }
                    .foregroundColor(.gray)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Comment")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
