import Foundation

final class TaskListInteractor: TaskListInteractorInterface {
    // MARK: - Dependencies
    private let dataManager: DataManager
    
    // MARK: - Initialization
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - BaseInteractorInterface
    func initialize() {
        // Загрузка начальных данных при первом запуске
        dataManager.loadInitialTodos { _ in }
    }
    
    // MARK: - TaskListInteractorInterface
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        // Выполнение в фоновом потоке с помощью GCD
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(AppError.unknown("Interactor was deallocated")))
                }
                return
            }
            
            self.dataManager.fetchAllTasks { tasks in
                DispatchQueue.main.async {
                    completion(.success(tasks))
                }
            }
        }
    }
    
    func toggleTaskCompletion(task: Task, isCompleted: Bool, completion: @escaping (Result<Task, Error>) -> Void) {
        // Выполнение в фоновом потоке с помощью GCD
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(AppError.unknown("Interactor was deallocated")))
                }
                return
            }
            
            guard let title = task.title else {
                DispatchQueue.main.async {
                    completion(.failure(AppError.validationError("Task title is missing")))
                }
                return
            }
            
            self.dataManager.updateTask(task: task, title: title, description: task.taskDescription, isCompleted: isCompleted) { success in
                DispatchQueue.main.async {
                    if success {
                        // Создаем обновленную копию объекта для возврата
                        let updatedTask = task
                        updatedTask.isCompleted = isCompleted
                        completion(.success(updatedTask))
                    } else {
                        completion(.failure(AppError.coreDataError("Failed to update task")))
                    }
                }
            }
        }
    }
    
    func deleteTask(task: Task, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Выполнение в фоновом потоке с помощью GCD
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(AppError.unknown("Interactor was deallocated")))
                }
                return
            }
            
            self.dataManager.deleteTask(task: task) { success in
                DispatchQueue.main.async {
                    if success {
                        completion(.success(true))
                    } else {
                        completion(.failure(AppError.coreDataError("Failed to delete task")))
                    }
                }
            }
        }
    }
    
    func searchTasks(with query: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        // Выполнение в фоновом потоке с помощью GCD
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(AppError.unknown("Interactor was deallocated")))
                }
                return
            }
            
            self.dataManager.searchTasks(with: query) { tasks in
                DispatchQueue.main.async {
                    completion(.success(tasks))
                }
            }
        }
    }
} 