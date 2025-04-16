import Foundation
import CoreData

/// Протокол для работы со стеком CoreData
protocol CoreDataStackProtocol {
    /// Контекст для выполнения операций в главном потоке
    var mainContext: NSManagedObjectContext { get }
    
    /// Создает контекст для выполнения фоновых операций
    func newBackgroundContext() -> NSManagedObjectContext
    
    /// Сохраняет изменения в контексте Core Data
    /// - Throws: Ошибку, если сохранение не удалось
    func saveContext() throws
    
    /// Сохраняет изменения в указанном контексте
    /// - Parameter context: Контекст, в котором нужно сохранить изменения
    /// - Throws: Ошибку, если сохранение не удалось
    func save(context: NSManagedObjectContext) throws
} 