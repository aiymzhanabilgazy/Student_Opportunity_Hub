import Foundation
import CoreData

final class CoreDataStack {

    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    var context: NSManagedObjectContext { container.viewContext }

    private init() {
        container = NSPersistentContainer(name: "StudentOpportunityHubModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load error: \(error)")
            }
        }

        // Полезно для merge (если много апдейтов)
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveIfNeeded() {
        let ctx = container.viewContext
        guard ctx.hasChanges else { return }
        do { try ctx.save() }
        catch { print("Core Data save error:", error) }
    }
}
