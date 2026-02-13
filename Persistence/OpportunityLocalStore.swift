import Foundation
import CoreData

protocol OpportunityLocalStoreProtocol {
    func fetchAll(limit: Int?) throws -> [Opportunity]
    func fetchCustom() throws -> [Opportunity]            // ✅ NEW
    func upsert(_ items: [Opportunity], source: String) throws
    func deleteAllRemote() throws
}

final class OpportunityLocalStore: OpportunityLocalStoreProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    func fetchAll(limit: Int? = nil) throws -> [Opportunity] {
        let req = CDOpportunity.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        if let limit { req.fetchLimit = limit }

        let entities = try context.fetch(req)
        return entities.map { $0.toDomain() }
    }

    // ✅ NEW: только созданные пользователем (source == "custom")
    func fetchCustom() throws -> [Opportunity] {
        let req = CDOpportunity.fetchRequest()
        req.predicate = NSPredicate(format: "source == %@", "custom")
        req.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        let entities = try context.fetch(req)
        return entities.map { $0.toDomain() }
    }

    func upsert(_ items: [Opportunity], source: String = "remote") throws {
        guard !items.isEmpty else { return }

        let ids = items.map { $0.id }

        let req = CDOpportunity.fetchRequest()
        req.predicate = NSPredicate(format: "id IN %@", ids)

        let existing = try context.fetch(req)
        var map: [String: CDOpportunity] = [:]
        existing.forEach { map[$0.id ?? ""] = $0 }

        let now = Date()

        for item in items {
            let obj = map[item.id] ?? CDOpportunity(context: context)
            obj.id = item.id
            obj.title = item.title
            obj.opportunityDescription = item.description
            obj.country = item.country
            obj.deadline = item.deadline
            obj.type = item.type
            obj.tagsCSV = item.tags.joined(separator: ",")
            obj.imageURL = item.imageURL
            obj.updatedAt = now
            obj.source = source   // ✅ важное
        }

        try context.save()
    }

    func deleteAllRemote() throws {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "CDOpportunity")
        req.predicate = NSPredicate(format: "source == %@", "remote") // ✅ custom не трогаем

        let deleteReq = NSBatchDeleteRequest(fetchRequest: req)
        try context.execute(deleteReq)
        try context.save()
    }
}

private extension CDOpportunity {
    func toDomain() -> Opportunity {
        Opportunity(
            id: self.id ?? UUID().uuidString,
            title: self.title ?? "",
            description: self.opportunityDescription ?? "",
            country: self.country ?? "Unknown",
            deadline: self.deadline ?? Date(),
            type: self.type ?? "Job",
            tags: (self.tagsCSV ?? "")
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty },
            imageURL: self.imageURL ?? ""
        )
    }
}
