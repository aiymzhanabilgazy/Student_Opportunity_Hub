import SwiftUI

struct CommentsView: View {
    
    @StateObject private var viewModel: CommentsViewModel
    
    init(opportunityId: String) {
        _viewModel = StateObject(wrappedValue: CommentsViewModel(opportunityId: opportunityId))
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.comments) { comment in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(comment.userName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(comment.text)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                
                Divider().background(Color.white)
                
                HStack {
                    TextField("Write a comment...", text: $viewModel.newCommentText)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    Button("Send") {
                        viewModel.addComment()
                    }
                    .foregroundColor(.accentBlue)
                }
                .padding()
            }
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
    }
}
