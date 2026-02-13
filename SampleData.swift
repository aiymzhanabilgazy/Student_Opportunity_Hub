import Foundation

struct SampleData {
    static let opportunities: [Opportunity] = [
        
        Opportunity(
            id: "1",
            title: "AI Hackathon 2026",
            description: "Join the biggest AI hackathon in Central Asia.",
            country: "Kazakhstan",
            deadline: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            type: "Hackathon",
            tags: ["AI", "IT", "Innovation"],
            imageURL: ""
        ),
        
        Opportunity(
            id: "2",
            title: "Summer Internship Google",
            description: "Internship program for Computer Science students.",
            country: "USA",
            deadline: Calendar.current.date(byAdding: .day, value: 12, to: Date())!,
            type: "Internship",
            tags: ["Tech", "Backend"],
            imageURL: ""
        ),
        
        Opportunity(
            id: "3",
            title: "European Research Grant",
            description: "Grant for students working on AI and sustainability research.",
            country: "Germany",
            deadline: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            type: "Grant",
            tags: ["Research", "AI", "Sustainability"],
            imageURL: ""
        ),
        
        Opportunity(
            id: "4",
            title: "UX Design Summer School",
            description: "Intensive 2-week summer program for aspiring UX designers.",
            country: "Netherlands",
            deadline: Calendar.current.date(byAdding: .day, value: 18, to: Date())!,
            type: "Summer School",
            tags: ["Design", "UX", "Creative"],
            imageURL: ""
        ),
        
        Opportunity(
            id: "5",
            title: "FinTech Startup Competition",
            description: "Pitch your fintech startup idea and win funding support.",
            country: "Singapore",
            deadline: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            type: "Competition",
            tags: ["Business", "Finance", "Startup"],
            imageURL: ""
        )
    ]
}
