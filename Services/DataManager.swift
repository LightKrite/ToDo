import Foundation
import CoreData

/// Протокол для управления данными задач
protocol DataManagerProtocol {
    /// Загружает начальный список задач
    /// - Parameter completion: Замыкание с результатом операции
    func fetchInitialTasks(completion: @escaping (Result<[Task], Error>) -> Void)
    
    /// Создает новую задачу
    /// - Parameters:
    ///   - title: Заголовок задачи
    ///   - description: Описание задачи
    ///   - isCompleted: Статус выполнения задачи
    ///   - completion: Замыкание с результатом операции
    func createTask(title: String, description: String, isCompleted: Bool, completion: @escaping (Result<Task, Error>) -> Void)
    
    /// Получает список всех задач
    /// - Parameter completion: Замыкание с результатом операции
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void)
    
    /// Выполняет поиск задач по запросу
    /// - Parameters:
    ///   - query: Поисковый запрос
    ///   - completion: Замыкание с результатом операции
    func searchTasks(with query: String, completion: @escaping (Result<[Task], Error>) -> Void)
    
    /// Обновляет существующую задачу
    /// - Parameters:
    ///   - task: Задача для обновления
    ///   - completion: Замыкание с результатом операции
    func updateTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void)
    
    /// Удаляет задачу
    /// - Parameters:
    ///   - task: Задача для удаления
    ///   - completion: Замыкание с результатом операции
    func deleteTask(_ task: Task, completion: @escaping (Result<Bool, Error>) -> Void)

    /// Сохраняет все изменения в основном контексте
    /// - Throws: Ошибку, если сохранение не удалось
    func saveContext() throws
}

/// Класс для управления данными задач
final class DataManager: DataManagerProtocol {
    // MARK: - Constants
    
    private enum Constants {
        static let defaultUserId: Int16 = 1
    }
    
    // MARK: - Dependencies
    
    private let coreDataStack: CoreDataStackProtocol
    private let networkService: NetworkServiceProtocol
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    
    /// Инициализатор менеджера данных
    /// - Parameters:
    ///   - coreDataStack: Стек Core Data для работы с локальными данными
    ///   - networkService: Сервис для работы с сетевыми данными
    ///   - logger: Сервис для логирования
    init(coreDataStack: CoreDataStackProtocol,
         networkService: NetworkServiceProtocol,
         logger: LoggerProtocol) {
        self.coreDataStack = coreDataStack
        self.networkService = networkService
        self.logger = logger
    }
    
    /// Статический метод для создания экземпляра с зависимостями по умолчанию
    static func createDefault(coreDataStack: CoreDataStackProtocol,
                             networkService: NetworkServiceProtocol = NetworkService(),
                             logger: LoggerProtocol = Logger.shared) -> DataManager {
        return DataManager(
            coreDataStack: coreDataStack,
            networkService: networkService,
            logger: logger
        )
    }
    
    // MARK: - DataManagerProtocol
    
    /// Загружает начальный список задач
    /// - Parameter completion: Замыкание с результатом операции
    func fetchInitialTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        logger.log("Начало загрузки начальных задач", level: .info)
        
        networkService.fetchTodos { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let tasks):
                self.logger.log("Успешно загружено \(tasks.count) задач", level: .info)
                completion(.success(tasks))
                
            case .failure(let error):
                self.logger.log("Ошибка при загрузке задач: \(error.localizedDescription)", level: .error)
                completion(.failure(error))
            }
        }
    }
    
    /// Создает новую задачу
    /// - Parameters:
    ///   - title: Заголовок задачи
    ///   - description: Описание задачи
    ///   - isCompleted: Статус выполнения задачи
    ///   - completion: Замыкание с результатом операции
    func createTask(title: String, description: String, isCompleted: Bool, completion: @escaping (Result<Task, Error>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let task = self.createLocalTask(title: title, description: description, isCompleted: isCompleted)
            
            do {
                try self.coreDataStack.saveContext()
                self.syncTaskWithServer(task, title: title, isCompleted: isCompleted)
                completion(.success(task))
            } catch {
                self.logger.log("Ошибка при создании задачи: \(error.localizedDescription)", level: .error)
                completion(.failure(error))
            }
        }
    }
    
    /// Получает список всех задач
    /// - Parameter completion: Замыкание с результатом операции
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let tasks = try self.coreDataStack.mainContext.fetch(fetchRequest)
                self.logger.log("Получено \(tasks.count) задач из базы данных", level: .info)
                completion(.success(tasks))
            } catch {
                self.logger.log("Ошибка при получении задач: \(error.localizedDescription)", level: .error)
                completion(.failure(error))
            }
        }
    }
    
    /// Выполняет поиск задач по запросу
    /// - Parameters:
    ///   - query: Поисковый запрос
    ///   - completion: Замыкание с результатом операции
    func searchTasks(with query: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            
            // Пустой запрос возвращает все задачи
            if !query.isEmpty {
                let predicate = NSPredicate(
                    format: "title CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@",
                    query, query
                )
                fetchRequest.predicate = predicate
            }
            
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let tasks = try self.coreDataStack.mainContext.fetch(fetchRequest)
                self.logger.log("Найдено \(tasks.count) задач по запросу: \(query)", level: .info)
                completion(.success(tasks))
            } catch {
                self.logger.log("Ошибка при поиске задач: \(error.localizedDescription)", level: .error)
                completion(.failure(error))
            }
        }
    }
    
    /// Обновляет существующую задачу
    /// - Parameters:
    ///   - task: Задача для обновления
    ///   - completion: Замыкание с результатом операции
    func updateTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.coreDataStack.saveContext()
                
                // Синхронизируем с сервером, если есть ID
                if let id = task.id {
                    self.networkService.updateTodoStatus(id: id, completed: task.isCompleted) { [weak self] result in
                        if case .failure(let error) = result {
                            self?.logger.log("Ошибка синхронизации задачи с сервером: \(error.localizedDescription)", level: .warning)
                        }
                    }
                }
                
                self.logger.log("Задача обновлена успешно", level: .info)
                completion(.success(task))
            } catch {
                self.logger.log("Ошибка при обновлении задачи: \(error.localizedDescription)", level: .error)
                completion(.failure(error))
            }
        }
    }
    
    /// Удаляет задачу
    /// - Parameters:
    ///   - task: Задача для удаления
    ///   - completion: Замыкание с результатом операции
    func deleteTask(_ task: Task, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Сохраняем идентификатор для синхронизации с сервером
            let taskId = task.id
            
            // Удаляем из локальной базы данных
            self.coreDataStack.mainContext.delete(task)
            
            do {
                try self.coreDataStack.saveContext()
                
                // Синхронизируем с сервером
                if let id = taskId {
                    self.networkService.deleteTodo(id: id) { [weak self] result in
                        if case .failure(let error) = result {
                            self?.logger.log("Ошибка удаления задачи на сервере: \(error.localizedDescription)", level: .warning)
                        }
                    }
                }
                
                self.logger.log("Задача успешно удалена", level: .info)
                completion(.success(true))
            } catch {
                self.logger.log("Ошибка при удалении задачи: \(error.localizedDescription)", level: .error)
                completion(.failure(error))
            }
        }
    }
    
    /// Сохраняет все изменения в основном контексте
    /// - Throws: Ошибку, если сохранение не удалось
    func saveContext() throws {
        try coreDataStack.saveContext()
    }
    
    // MARK: - Private Methods
    
    /// Создает новую задачу в локальной базе данных
    /// - Parameters:
    ///   - title: Заголовок задачи
    ///   - description: Описание задачи
    ///   - isCompleted: Статус выполнения
    /// - Returns: Созданная задача
    private func createLocalTask(title: String, description: String, isCompleted: Bool) -> Task {
        let task = Task(context: coreDataStack.mainContext)
        task.id = UUID().uuidString
        task.title = title
        task.taskDescription = description
        task.isCompleted = isCompleted
        task.userId = Constants.defaultUserId
        task.createdAt = Date()
        
        return task
    }
    
    /// Синхронизирует задачу с сервером
    /// - Parameters:
    ///   - task: Задача для синхронизации
    ///   - title: Заголовок задачи
    ///   - isCompleted: Статус выполнения
    private func syncTaskWithServer(_ task: Task, title: String, isCompleted: Bool) {
        networkService.createTodo(title: title, completed: isCompleted) { [weak self] result in
            switch result {
            case .success:
                self?.logger.log("Задача успешно синхронизирована с сервером", level: .info)
            case .failure(let error):
                self?.logger.log("Ошибка синхронизации с сервером: \(error.localizedDescription)", level: .warning)
            }
        }
    }
} 