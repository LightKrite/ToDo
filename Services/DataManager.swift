import Foundation

final class DataManager {
    
    // MARK: - Singleton
    static let shared = DataManager()
    
    private init() {}
    
    // MARK: - Dependencies
    private let networkService = NetworkService.shared
    private let coreDataStack = CoreDataStack.shared
    
    // MARK: - Public Methods
    
    /// Загрузка задач при первом запуске
    func loadInitialTodos(completion: @escaping (Bool) -> Void) {
        // Проверяем, есть ли уже задачи в CoreData
        coreDataStack.fetchAllTasks { tasks in
            if tasks.isEmpty {
                // Если задач нет, загружаем их из API
                self.fetchTodosFromAPI(completion: completion)
            } else {
                // Если задачи уже есть, просто возвращаем успех
                completion(true)
            }
        }
    }
    
    /// Загрузка задач из API
    func fetchTodosFromAPI(completion: @escaping (Bool) -> Void) {
        networkService.fetchTodos { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let todos):
                self.saveTodosToDatabase(todos: todos, completion: completion)
            case .failure(let error):
                print("Ошибка при загрузке задач: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// Создание новой задачи
    func createTask(title: String, description: String?, isCompleted: Bool, completion: @escaping (Task?) -> Void) {
        // Генерируем уникальный идентификатор
        let id = UUID().uuidString
        
        // Сохраняем задачу локально
        coreDataStack.createTask(id: id, title: title, description: description, isCompleted: isCompleted) { task in
            completion(task)
        }
        
        // Можно реализовать синхронизацию с API, но в данном случае это не требуется
    }
    
    /// Получение всех задач
    func fetchAllTasks(completion: @escaping ([Task]) -> Void) {
        coreDataStack.fetchAllTasks(completionHandler: completion)
    }
    
    /// Поиск задач
    func searchTasks(with query: String, completion: @escaping ([Task]) -> Void) {
        coreDataStack.searchTasks(with: query, completionHandler: completion)
    }
    
    /// Обновление задачи
    func updateTask(task: Task, title: String, description: String?, isCompleted: Bool, completion: @escaping (Bool) -> Void) {
        coreDataStack.updateTask(task: task, title: title, description: description, isCompleted: isCompleted) { success in
            completion(success)
        }
    }
    
    /// Удаление задачи
    func deleteTask(task: Task, completion: @escaping (Bool) -> Void) {
        coreDataStack.deleteTask(task: task) { success in
            completion(success)
        }
    }
    
    // MARK: - Private Methods
    
    /// Сохранение задач в базу данных
    private func saveTodosToDatabase(todos: [TodoModel], completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var success = true
        
        for todo in todos {
            group.enter()
            
            let taskData = todo.asCoreDataTask()
            coreDataStack.createTask(
                id: taskData.id,
                title: taskData.title,
                description: taskData.description,
                isCompleted: taskData.isCompleted
            ) { task in
                if task == nil {
                    success = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(success)
        }
    }
} 