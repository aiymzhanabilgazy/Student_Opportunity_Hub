import SwiftUI

struct AddOpportunityView: View {
    
    @EnvironmentObject var appState: AppState
    
    @State private var title = ""
    @State private var description = ""
    @State private var country = ""
    @State private var type = ""
    @State private var deadline = Date()
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        TextField("Title", text: $title)
                            .styledField()
                        
                        TextField("Description", text: $description)
                            .styledField()
                        
                        TextField("Country", text: $country)
                            .styledField()
                        
                        TextField("Type", text: $type)
                            .styledField()
                        
                        DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                            .foregroundColor(.white)
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        
                        Button("Add Opportunity") {
                            validateAndAdd()
                        }
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentBlue)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Opportunity")
        }
        .preferredColorScheme(.dark)
    }
    
    private func validateAndAdd() {
        if title.isEmpty || description.isEmpty || country.isEmpty || type.isEmpty {
            errorMessage = "Please fill all fields"
            return
        }
        
        if deadline < Date() {
            errorMessage = "Deadline cannot be in the past"
            return
        }
        
        errorMessage = ""
        
        appState.addOpportunity(
            title: title,
            description: description,
            country: country,
            deadline: deadline,
            type: type
        )
        
        title = ""
        description = ""
        country = ""
        type = ""
    }
}
extension View {
    func styledField() -> some View {
        self
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .foregroundColor(.white)
    }
}

