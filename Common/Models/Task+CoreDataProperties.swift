import Foundation
import CoreData

extension Task {
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var userId: Int16
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }
} 