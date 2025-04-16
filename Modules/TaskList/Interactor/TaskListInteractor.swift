import Foundation

final class TaskListInteractor: TaskListInteractorInterface {
    // MARK: - VIPER
    weak var presenter: TaskListPresenterInterface?
    
    // MARK: - Dependencies
    let dataManager: DataManagerProtocol
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    init(dataManager: DataManagerProtocol, logger: LoggerProtocol) {
        self.dataManager = dataManager
        self.logger = logger
    }
    
    // MARK: - BaseInteractorInterface
    func initialize() {
        print("DEBUG: TaskListInteractor - initialize вызван")
        
        // Загружаем начальные данные
        // Делаем с небольшой задержкой, чтобы дать приложению время инициализироваться
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            print("DEBUG: TaskListInteractor - загружаем начальные данные")
            
            self.dataManager.fetchInitialTasks { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let tasks):
                    print("DEBUG: TaskListInteractor - начальные данные успешно загружены, получено \(tasks.count) задач")
                    self.logger.log("Initial tasks loaded successfully, count: \(tasks.count)", level: .info)
                    
                    // Проверяем несколько задач для отладки
                    if tasks.count > 0 {
                        print("DEBUG: TaskListInteractor - примеры загруженных задач:")
                        for (index, task) in tasks.prefix(3).enumerated() {
                            print("DEBUG: TaskListInteractor - задача \(index): id=\(task.id ?? "nil"), title='\(task.title ?? "nil")' (пустой: \(task.title?.isEmpty ?? true))")
                        }
                    }
                    
                    // Переключаемся в главный поток для обновления UI
                    DispatchQueue.main.async {
                        // Обновляем отображение на экране
                        self.fetchAllTasks { result in
                            switch result {
                            case .success(let tasks):
                                print("DEBUG: TaskListInteractor - fetchAllTasks после загрузки вернул \(tasks.count) задач")
                                
                                // Восстанавливаем обновление UI, но с защитой от зацикливания
                                if let completion = self.lastFetchCompletion {
                                    print("DEBUG: TaskListInteractor - вызываем обновление UI с \(tasks.count) задачами")
                                    
                                    // Сохраняем копию и очищаем ссылку перед вызовом, чтобы избежать зацикливания
                                    let savedCompletion = completion
                                    self.lastFetchCompletion = nil
                                    
                                    // Вызываем сохраненный completion с результатом
                                    savedCompletion(.success(tasks))
                                }
                            case .failure(let error):
                                print("DEBUG: TaskListInteractor - fetchAllTasks после загрузки вернул ошибку: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("DEBUG: TaskListInteractor - ошибка при загрузке начальных данных: \(error.localizedDescription)")
                    self.logger.log(error, level: .error)
                }
            }
        }
    }
    
    // Храним последний completion handler для возможности обновления UI
    private var lastFetchCompletion: ((Result<[Task], Error>) -> Void)?
    
    // MARK: - TaskListInteractorInterface
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        print("DEBUG: TaskListInteractor - fetchAllTasks вызван")
        
        // Сохраняем completion для возможного повторного использования
        // Но сначала проверим, что это не повторный вызов
        if self.lastFetchCompletion == nil {
            self.lastFetchCompletion = completion
        }
        
        // Получаем все задачи через DataManager
        // Выполняем только в главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("DEBUG: TaskListInteractor - вызываем dataManager.fetchAllTasks")
            self.dataManager.fetchAllTasks { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let tasks):
                    // Задачи успешно получены
                    print("DEBUG: TaskListInteractor - успешно получено \(tasks.count) задач")
                    completion(.success(tasks))
                case .failure(let error):
                    // Логируем ошибку
                    print("DEBUG: TaskListInteractor - ошибка при получении задач: \(error.localizedDescription)")
                    self.logger.log(error, level: .error)
                    // Возвращаем ошибку в обертке TaskError
                    completion(.failure(TaskError.databaseError(error)))
                }
            }
        }
    }
    
    // Реализуем метод из протокола, который отсутствовал
    func fetchInitialData(completion: @escaping (Result<[Task], Error>) -> Void) {
        print("DEBUG: TaskListInteractor - fetchInitialData вызван")
        fetchAllTasks(completion: completion)
    }
    
    func updateTask(task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        print("DEBUG: Interactor - updateTask вызван с задачей \(task.title ?? "без заголовка")")
        
        // Проверяем валидность задачи
        guard task.title != nil else {
            let error = TaskError.invalidData
            logger.log("Попытка обновить задачу с пустым заголовком", level: .error)
            print("DEBUG: Interactor - ошибка: пустой заголовок задачи")
            completion(.failure(error))
            return
        }
        
        // Выполняем только в главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Обновляем задачу через DataManager
            print("DEBUG: Interactor - вызываем dataManager.updateTask")
            self.dataManager.updateTask(task) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let updatedTask):
                    // Задача успешно обновлена
                    print("DEBUG: Interactor - задача успешно обновлена")
                    completion(.success(updatedTask))
                case .failure(let error):
                    // Логируем ошибку
                    self.logger.log(error, level: .error)
                    print("DEBUG: Interactor - ошибка при обновлении: \(error.localizedDescription)")
                    // Возвращаем ошибку в обертке TaskError
                    completion(.failure(TaskError.databaseError(error)))
                }
            }
        }
    }
    
    func deleteTask(task: Task, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Проверяем валидность задачи
        guard task.title != nil else {
            let error = TaskError.invalidData
            logger.log("Попытка удалить задачу с пустым заголовком", level: .error)
            completion(.failure(error))
            return
        }
        
        // Выполняем только в главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Удаляем задачу через DataManager
            self.dataManager.deleteTask(task) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    // Задача успешно удалена
                    self.logger.log("Задача успешно удалена", level: .info)
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
    
    func searchTasks(with query: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        // Проверяем валидность запроса
        guard !query.isEmpty else {
            let error = TaskError.invalidData
            logger.log("Попытка поиска с пустым запросом", level: .warning)
            completion(.failure(error))
            return
        }
        
        // Выполняем только в главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Выполняем поиск через DataManager
            self.dataManager.searchTasks(with: query) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let tasks):
                    // Задачи успешно найдены
                    completion(.success(tasks))
                case .failure(let error):
                    // Логируем ошибку
                    self.logger.log(error, level: .error)
                    // Возвращаем ошибку в обертке TaskError
                    completion(.failure(TaskError.databaseError(error)))
                }
            }
        }
    }
} 