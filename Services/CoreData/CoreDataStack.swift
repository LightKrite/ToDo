import Foundation
import CoreData
import UIKit

/// Класс для управления стеком Core Data
final class CoreDataStack: CoreDataStackProtocol {
    
    // MARK: - Core Data Stack
    
    /// Контейнер постоянного хранилища для модели данных
    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDo")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Не удалось загрузить постоянное хранилище: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    /// Контекст для выполнения операций в главном потоке
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Контекст для выполнения фоновых операций
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Core Data Saving
    
    /// Сохраняет изменения в контексте Core Data
    /// - Throws: Ошибку, если сохранение не удалось
    func saveContext() throws {
        let context = mainContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// Сохраняет изменения в указанном контексте
    /// - Parameter context: Контекст, в котором нужно сохранить изменения
    /// - Throws: Ошибку, если сохранение не удалось
    func save(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    // MARK: - Core Data Operations
    
    /// Выполняет операцию с данными в фоновом контексте
    /// - Parameters:
    ///   - operation: Операция для выполнения
    ///   - completion: Замыкание, вызываемое после завершения операции
    func performBackgroundTask(_ operation: @escaping (NSManagedObjectContext) -> Void, completion: (() -> Void)? = nil) {
        let context = newBackgroundContext()
        context.perform {
            operation(context)
            completion?()
        }
    }
    
    /// Выполняет операцию с данными в фоновом контексте и сохраняет изменения
    /// - Parameters:
    ///   - operation: Операция для выполнения
    ///   - completion: Замыкание, вызываемое после завершения операции с результатом
    func performBackgroundTaskAndSave(_ operation: @escaping (NSManagedObjectContext) -> Void, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let context = newBackgroundContext()
        context.perform {
            operation(context)
            
            do {
                if context.hasChanges {
                    try context.save()
                }
                completion?(.success(()))
            } catch {
                completion?(.failure(error))
            }
        }
    }
    
    // MARK: - Initialization
    
    /// Инициализирует стек CoreData
    /// - Parameter shouldSetupNotificationHandling: Нужно ли настраивать обработку системных уведомлений
    init(shouldSetupNotificationHandling: Bool = true) {
        if shouldSetupNotificationHandling {
            setupNotificationHandling()
        }
    }
    
    // MARK: - Private Methods
    
    /// Настраивает обработку уведомлений
    private func setupNotificationHandling() {
        // Наблюдение за уведомлениями о завершении работы приложения
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveChangesBeforeTermination(_:)),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    /// Сохраняет изменения перед завершением работы приложения
    @objc private func saveChangesBeforeTermination(_ notification: Notification) {
        do {
            try saveContext()
        } catch {
            print("Ошибка при сохранении данных перед завершением работы: \(error)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
} 