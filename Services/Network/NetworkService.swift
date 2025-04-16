import Foundation
import CoreData

/// Класс, реализующий сетевые операции для работы с задачами
final class NetworkService: NetworkServiceProtocol {
    // MARK: - Dependencies
    
    private let coreDataStack: CoreDataStackProtocol
    private let logger: LoggerProtocol
    
    // MARK: - Constants
    
    private enum Constants {
        static let baseURL = "https://dummyjson.com/todos"
        static let maxTasksToProcess = 20
        static let requestTimeout: TimeInterval = 15
    }
    
    // MARK: - Initialization
    
    init(coreDataStack: CoreDataStackProtocol, logger: LoggerProtocol = Logger.shared) {
        self.coreDataStack = coreDataStack
        self.logger = logger
    }
    
    // MARK: - NetworkServiceProtocol
    
    /// Загружает список задач с сервера
    /// - Parameter completion: Замыкание для обработки результата запроса
    func fetchTodos(completion: @escaping (Result<[Task], Error>) -> Void) {
        logger.log("Начинаем загрузку задач из API", level: .info)
        
        guard let url = URL(string: Constants.baseURL) else {
            let error = NetworkError.invalidURL
            logger.log(error, level: .error)
            completion(.failure(error))
            return
        }
        
        logger.log("Отправляем запрос к URL: \(url.absoluteString)", level: .debug)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Обработка ошибки
            if let error = error {
                let networkError = NetworkError.networkError(error)
                self.logger.log(networkError, level: .error)
                completion(.failure(networkError))
                return
            }
            
            // Проверка кода ответа
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let serverError = NetworkError.serverError(httpResponse.statusCode)
                self.logger.log(serverError, level: .error)
                completion(.failure(serverError))
                return
            }
            
            // Проверка наличия данных
            guard let data = data else {
                let noDataError = NetworkError.noData
                self.logger.log(noDataError, level: .error)
                completion(.failure(noDataError))
                return
            }
            
            self.logger.log("Получены данные размером: \(data.count) байт", level: .debug)
            
            // Декодирование данных
            do {
                let todosResponse = try self.decodeTodosResponse(from: data)
                self.processTodos(todosResponse.todos, completion: completion)
            } catch {
                let decodingError = NetworkError.decodingError(error)
                self.logger.log(decodingError, level: .error)
                completion(.failure(decodingError))
            }
        }
        
        task.resume()
    }
    
    /// Создает новую задачу
    /// - Parameters:
    ///   - title: Заголовок задачи
    ///   - completed: Статус выполнения задачи
    ///   - completion: Замыкание для обработки результата запроса
    func createTodo(title: String, completed: Bool, completion: @escaping (Result<Task, Error>) -> Void) {
        // Создаем локальную заглушку успешного ответа
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Создаем задачу в Core Data
            let context = self.coreDataStack.mainContext
            let task = Task(context: context)
            task.id = UUID().uuidString
            task.title = title
            task.isCompleted = completed
            task.createdAt = Date()
            task.userId = 1
            task.taskDescription = "Локально созданная задача"
            
            do {
                try self.coreDataStack.saveContext()
                self.logger.log("Создана новая задача", level: .info)
                completion(.success(task))
            } catch {
                self.logger.log("Ошибка при создании задачи: \(error.localizedDescription)", level: .error)
                completion(.failure(TaskError.saveFailed))
            }
        }
    }
    
    /// Обновляет статус задачи
    /// - Parameters:
    ///   - id: Идентификатор задачи
    ///   - completed: Новый статус выполнения
    ///   - completion: Замыкание для обработки результата запроса
    func updateTodoStatus(id: String?, completed: Bool, completion: @escaping (Result<Task, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let id = id else {
                self.logger.log("Попытка обновить задачу с пустым идентификатором", level: .error)
                completion(.failure(TaskError.invalidData))
                return
            }
            
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let context = self.coreDataStack.mainContext
                let tasks = try context.fetch(fetchRequest)
                
                if let task = tasks.first {
                    task.isCompleted = completed
                    try self.coreDataStack.saveContext()
                    self.logger.log("Обновлен статус задачи: \(id)", level: .info)
                    completion(.success(task))
                } else {
                    self.logger.log("Задача не найдена: \(id)", level: .warning)
                    completion(.failure(TaskError.taskNotFound))
                }
            } catch {
                self.logger.log("Ошибка при обновлении задачи: \(error.localizedDescription)", level: .error)
                completion(.failure(error))
            }
        }
    }
    
    /// Удаляет задачу с сервера
    /// - Parameters:
    ///   - id: Идентификатор задачи для удаления
    ///   - completion: Замыкание для обработки результата запроса
    func deleteTodo(id: String?, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let id = id else {
                self.logger.log("Попытка удалить задачу с пустым идентификатором", level: .warning)
                completion(.success(true))
                return
            }
            
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let context = self.coreDataStack.mainContext
                let tasks = try context.fetch(fetchRequest)
                
                if let task = tasks.first {
                    context.delete(task)
                    try self.coreDataStack.saveContext()
                    self.logger.log("Удалена задача: \(id)", level: .info)
                } else {
                    self.logger.log("Задача для удаления не найдена: \(id)", level: .warning)
                }
                
                completion(.success(true))
            } catch {
                self.logger.log("Ошибка при удалении задачи: \(error.localizedDescription)", level: .error)
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Декодирует ответ сервера с задачами
    /// - Parameter data: Данные для декодирования
    /// - Returns: Объект с декодированными задачами
    private func decodeTodosResponse(from data: Data) throws -> TodosResponse {
        let decoder = JSONDecoder()
        return try decoder.decode(TodosResponse.self, from: data)
    }
    
    /// Обрабатывает загруженные задачи и сохраняет их в базу данных
    /// - Parameters:
    ///   - todos: Список задач из API
    ///   - completion: Замыкание для обработки результата
    private func processTodos(_ todos: [TaskDTO], completion: @escaping (Result<[Task], Error>) -> Void) {
        DispatchQueue.main.async {
            let context = self.coreDataStack.mainContext
            var newTasksCount = 0
            let existingTaskIds = self.fetchExistingTaskIds(in: context)
            
            // Обрабатываем задачи из API с ограничением количества
            for networkTask in todos.prefix(Constants.maxTasksToProcess) {
                let taskId = "\(networkTask.id)"
                
                // Пропускаем уже существующие задачи
                if existingTaskIds.contains(taskId) { continue }
                
                // Создаем новую задачу
                let task = Task(context: context)
                task.id = taskId
                task.title = networkTask.todo
                task.taskDescription = "Задача из API"
                task.isCompleted = networkTask.completed
                task.createdAt = Date()
                task.userId = Int16(networkTask.userId)
                
                newTasksCount += 1
            }
            
            if newTasksCount > 0 {
                do {
                    try self.coreDataStack.saveContext()
                    self.logger.log("Добавлено \(newTasksCount) новых задач", level: .info)
                } catch {
                    self.logger.log("Ошибка сохранения задач: \(error.localizedDescription)", level: .error)
                    completion(.failure(NetworkError.networkError(error)))
                    return
                }
            }
            
            // Возвращаем все задачи
            self.fetchAllTasks(completion: completion)
        }
    }
    
    /// Получает идентификаторы существующих задач
    /// - Parameter context: Контекст Core Data
    /// - Returns: Множество идентификаторов задач
    private func fetchExistingTaskIds(in context: NSManagedObjectContext) -> Set<String> {
        var existingTaskIds = Set<String>()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            let existingTasks = try context.fetch(fetchRequest)
            for task in existingTasks {
                if let id = task.id {
                    existingTaskIds.insert(id)
                }
            }
            logger.log("Найдено \(existingTaskIds.count) существующих задач", level: .debug)
        } catch {
            logger.log("Ошибка при проверке существующих задач: \(error.localizedDescription)", level: .error)
        }
        
        return existingTaskIds
    }
    
    /// Получает все задачи из базы данных
    /// - Parameter completion: Замыкание для обработки результата
    private func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let allTasks = try self.coreDataStack.mainContext.fetch(fetchRequest)
            completion(.success(allTasks))
        } catch {
            let fetchError = NetworkError.networkError(error)
            logger.log(fetchError, level: .error)
            completion(.failure(fetchError))
        }
    }
} 