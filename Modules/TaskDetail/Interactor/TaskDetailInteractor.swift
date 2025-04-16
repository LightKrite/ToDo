import Foundation
import CoreData

final class TaskDetailInteractor: TaskDetailInteractorInterface {
    
    // MARK: - VIPER
    weak var presenter: TaskDetailPresenterInterface?
    
    // MARK: - Dependencies
    let dataManager: DataManagerProtocol
    private(set) var task: Task
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    init(task: Task,
         dataManager: DataManagerProtocol,
         logger: LoggerProtocol) {
        self.task = task
        self.dataManager = dataManager
        self.logger = logger
    }
    
    // MARK: - BaseInteractorInterface
    func initialize() { }
    
    // MARK: - TaskDetailInteractorInterface
    func getTask(completion: @escaping (Result<Task, Error>) -> Void) {
        completion(.success(task))
    }
    
    func updateTask(title: String, description: String?, isCompleted: Bool, completion: @escaping (Result<Task, Error>) -> Void) {
        // Проверяем наличие заголовка
        guard !title.isEmpty else {
            let error = TaskError.invalidData
            logger.log("Пустой заголовок задачи", level: .error)
            completion(.failure(error))
            return
        }
        
        // Обновляем свойства задачи
        task.title = title
        task.taskDescription = description
        task.isCompleted = isCompleted
        
        // Обновляем задачу через DataManager
        dataManager.updateTask(task) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let updatedTask):
                // Обновляем текущую задачу
                self.task = updatedTask
                // Логируем успешное обновление
                self.logger.log("Задача успешно обновлена: \(updatedTask.title ?? "")", level: .info)
                // Возвращаем обновленную задачу
                completion(.success(updatedTask))
            case .failure(let error):
                // Логируем ошибку
                self.logger.log(error, level: .error)
                // Возвращаем ошибку в обертке TaskError
                completion(.failure(TaskError.databaseError(error)))
            }
        }
    }
    
    func deleteTask(_ task: Task, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Проверяем валидность идентификатора
        guard task.id != nil else {
            let error = TaskError.invalidData
            logger.log("Попытка удалить задачу без идентификатора", level: .error)
            completion(.failure(error))
            return
        }
        
        // Удаляем задачу через DataManager
        dataManager.deleteTask(task) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // Логируем успешное удаление
                self.logger.log("Задача успешно удалена", level: .info)
                // Возвращаем флаг успешного удаления
                completion(.success(true))
            case .failure(let error):
                // Логируем ошибку
                self.logger.log(error, level: .error)
                // Возвращаем ошибку в обертке TaskError
                completion(.failure(TaskError.databaseError(error)))
            }
        }
    }
} 