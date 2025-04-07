import Foundation
import CoreData
import UIKit

/// Класс для управления стеком Core Data
final class CoreDataStack {
    
    // MARK: - Singleton
    
    /// Общий экземпляр стека Core Data
    static let shared = CoreDataStack()
    
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
    
    private init() {
        setupNotificationHandling()
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
    
    // MARK: - Task Operations
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            // Сортировка по дате создания (от новых к старым)
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Выполняем запрос на получение задач
            let tasks = try mainContext.fetch(fetchRequest)
            completion(.success(tasks))
        } catch {
            completion(.failure(error))
        }
    }
    
    func searchTasks(with query: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            // Создаем предикат для поиска по заголовку или описанию
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
            let descriptionPredicate = NSPredicate(format: "taskDescription CONTAINS[cd] %@", query)
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, descriptionPredicate])
            fetchRequest.predicate = compoundPredicate
            
            // Сортировка по дате создания (от новых к старым)
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Выполняем запрос на получение задач
            let tasks = try mainContext.fetch(fetchRequest)
            completion(.success(tasks))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteTask(_ task: Task, completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            // Удаляем задачу из контекста
            mainContext.delete(task)
            
            // Сохраняем контекст
            try saveContext()
            
            // Возвращаем успех
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - CRUD операции
    
    // Создание новой задачи
    func createTask(_ task: Task) throws -> Task {
        try saveContext()
        return task
    }
    
    // Обновление задачи
    func updateTask(_ task: Task) throws -> Task {
        try saveContext()
        return task
    }
    
    // Сохранение массива задач
    func saveTasks(_ tasks: [Task]) throws {
        try saveContext()
    }
}

enum CoreDataError: LocalizedError {
    case taskNotFound
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .taskNotFound:
            return "Задача не найдена"
        case .saveFailed(let error):
            return "Ошибка сохранения: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Ошибка получения данных: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Ошибка удаления: \(error.localizedDescription)"
        }
    }
} 