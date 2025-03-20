import Foundation

// MARK: - ViewModels

/// ViewModel для отображения задачи в списке
struct TaskViewModel {
    let id: String
    let title: String
    let description: String?
    let createdAt: Date
    let isCompleted: Bool
    
    /// Создание из Core Data модели
    init(task: Task) {
        self.id = task.id ?? ""
        self.title = task.title ?? ""
        self.description = task.taskDescription
        self.createdAt = task.createdAt ?? Date()
        self.isCompleted = task.isCompleted
    }
    
    /// Форматированная дата создания
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}

// MARK: - TaskList Module Protocols

/// Протокол для View модуля TaskList
protocol TaskListViewInterface: BaseViewInterface {
    /// Отображение списка задач
    func displayTasks(_ tasks: [TaskViewModel])
    
    /// Обновление задачи по индексу
    func updateTask(at index: Int, with viewModel: TaskViewModel)
    
    /// Удаление задачи по индексу
    func removeTask(at index: Int)
    
    /// Добавление новой задачи
    func insertTask(_ viewModel: TaskViewModel, at index: Int)
    
    /// Отображение результатов поиска
    func displaySearchResults(_ tasks: [TaskViewModel])
    
    /// Очистка результатов поиска
    func clearSearchResults()
}

/// Протокол для Presenter модуля TaskList
protocol TaskListPresenterInterface: BasePresenterInterface {
    /// Получить все задачи
    func fetchTasks()
    
    /// Обработка выбора задачи
    func didSelectTask(at index: Int)
    
    /// Обработка нажатия на кнопку добавления задачи
    func didTapAddTask()
    
    /// Обработка переключения статуса задачи
    func didToggleTaskCompletion(at index: Int, isCompleted: Bool)
    
    /// Обработка удаления задачи
    func didTapDeleteTask(at index: Int)
    
    /// Обработка поиска задач
    func searchTasks(with query: String)
    
    /// Очистка поиска
    func clearSearch()
}

/// Протокол для Interactor модуля TaskList
protocol TaskListInteractorInterface: BaseInteractorInterface {
    /// Получить все задачи
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void)
    
    /// Изменить статус задачи
    func toggleTaskCompletion(task: Task, isCompleted: Bool, completion: @escaping (Result<Task, Error>) -> Void)
    
    /// Удалить задачу
    func deleteTask(task: Task, completion: @escaping (Result<Bool, Error>) -> Void)
    
    /// Поиск задач
    func searchTasks(with query: String, completion: @escaping (Result<[Task], Error>) -> Void)
}

/// Протокол для Router модуля TaskList
protocol TaskListRouterInterface: BaseRouterInterface {
    /// Переход к экрану просмотра/редактирования задачи
    func navigateToTaskDetail(with task: Task)
    
    /// Переход к экрану создания задачи
    func navigateToCreateTask()
}

// MARK: - TaskDetail Module Protocols

/// Протокол для View модуля TaskDetail
protocol TaskDetailViewInterface: BaseViewInterface {
    /// Отображение данных задачи
    func displayTask(_ viewModel: TaskViewModel)
    
    /// Переключение в режим редактирования
    func enterEditMode()
    
    /// Переключение в режим просмотра
    func exitEditMode()
}

/// Протокол для Presenter модуля TaskDetail
protocol TaskDetailPresenterInterface: BasePresenterInterface {
    /// Обработка редактирования задачи
    func didTapEditTask()
    
    /// Обработка сохранения задачи
    func didTapSaveTask(title: String, description: String?, isCompleted: Bool)
    
    /// Обработка удаления задачи
    func didTapDeleteTask()
    
    /// Обработка изменения статуса задачи
    func didToggleTaskCompletion(isCompleted: Bool)
}

/// Протокол для Interactor модуля TaskDetail
protocol TaskDetailInteractorInterface: BaseInteractorInterface {
    /// Получить задачу по ID
    func fetchTask(with id: String, completion: @escaping (Result<Task, Error>) -> Void)
    
    /// Обновить задачу
    func updateTask(task: Task, title: String, description: String?, isCompleted: Bool, completion: @escaping (Result<Task, Error>) -> Void)
    
    /// Удалить задачу
    func deleteTask(task: Task, completion: @escaping (Result<Bool, Error>) -> Void)
}

/// Протокол для Router модуля TaskDetail
protocol TaskDetailRouterInterface: BaseRouterInterface {
    /// Вернуться к списку задач
    func navigateBackToTaskList()
}

// MARK: - CreateTask Module Protocols

/// Протокол для View модуля CreateTask
protocol CreateTaskViewInterface: BaseViewInterface {
    /// Закрытие экрана после создания задачи
    func closeScreen()
}

/// Протокол для Presenter модуля CreateTask
protocol CreateTaskPresenterInterface: BasePresenterInterface {
    /// Обработка создания задачи
    func didTapCreateTask(title: String, description: String?, isCompleted: Bool)
    
    /// Обработка отмены создания
    func didTapCancel()
}

/// Протокол для Interactor модуля CreateTask
protocol CreateTaskInteractorInterface: BaseInteractorInterface {
    /// Создать новую задачу
    func createTask(title: String, description: String?, isCompleted: Bool, completion: @escaping (Result<Task, Error>) -> Void)
}

/// Протокол для Router модуля CreateTask
protocol CreateTaskRouterInterface: BaseRouterInterface {
    /// Закрыть экран создания задачи
    func dismissCreateTask()
} 