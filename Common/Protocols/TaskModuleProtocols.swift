import Foundation
import UIKit
import CoreData

// MARK: - TaskList Module Protocols

/// Протокол для Presenter модуля TaskList
protocol TaskListPresenterInterface: AnyObject {
    var view: TaskListViewInterface? { get set }
    var interactor: TaskListInteractorInterface? { get set }
    var router: TaskListRouterInterface? { get set }
    
    func viewDidLoad()
    func viewWillAppear()
    func fetchTasks()
    func didTapAddTask()
    func didTapTask(at index: Int)
    func didTapDeleteTask(at index: Int)
    func didToggleTaskCompletion(at index: Int)
    func searchTasks(with query: String)
    func clearSearch()
}

/// Протокол для View модуля TaskList
protocol TaskListViewInterface: AnyObject {
    func displayTasks(_ tasks: [TaskViewModel])
    func displayError(_ message: String)
    
    // Методы для обратной совместимости
    func showError(_ message: String)
    func showLoading()
    func hideLoading()
    
    // Методы для работы с поиском
    func displaySearchResults(_ tasks: [TaskViewModel])
    func clearSearchResults()
    
    // Методы для работы с отдельными задачами
    func updateTask(at index: Int, with viewModel: TaskViewModel)
    func removeTask(at index: Int)
    func insertTask(_ viewModel: TaskViewModel, at index: Int)
}

/// Протокол для Interactor модуля TaskList
protocol TaskListInteractorInterface: AnyObject {
    var presenter: TaskListPresenterInterface? { get set }
    var dataManager: DataManagerProtocol { get }
    
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void)
    func fetchInitialData(completion: @escaping (Result<[Task], Error>) -> Void)
    func searchTasks(with query: String, completion: @escaping (Result<[Task], Error>) -> Void)
    func updateTask(task: Task, completion: @escaping (Result<Task, Error>) -> Void)
    func deleteTask(task: Task, completion: @escaping (Result<Bool, Error>) -> Void)
}

/// Протокол для Router модуля TaskList
protocol TaskListRouterInterface: AnyObject {
    var viewController: UIViewController? { get set }
    
    func navigateToTaskDetail(with task: Task)
    func navigateToCreateTask()
}

// MARK: - TaskDetail Module Protocols

/// Протокол для Presenter модуля TaskDetail
protocol TaskDetailPresenterInterface: AnyObject {
    var view: TaskDetailViewInterface? { get set }
    var interactor: TaskDetailInteractorInterface? { get set }
    var router: TaskDetailRouterInterface? { get set }
    
    func viewDidLoad()
    func didTapSaveTask(title: String, description: String?, isCompleted: Bool)
    func didTapDeleteTask()
    func didTapEditTask()
    func didTapCancelEdit()
    func didToggleTaskCompletion(isCompleted: Bool)
}

/// Протокол для View модуля TaskDetail
protocol TaskDetailViewInterface: AnyObject {
    func displayTask(_ viewModel: TaskViewModel)
    func displayError(_ message: String)
    func enterEditMode()
    func exitEditMode()
}

/// Протокол для Interactor модуля TaskDetail
protocol TaskDetailInteractorInterface: AnyObject {
    var presenter: TaskDetailPresenterInterface? { get set }
    var task: Task { get }
    var dataManager: DataManagerProtocol { get }
    
    func getTask(completion: @escaping (Result<Task, Error>) -> Void)
    func updateTask(title: String, description: String?, isCompleted: Bool, completion: @escaping (Result<Task, Error>) -> Void)
    func deleteTask(_ task: Task, completion: @escaping (Result<Bool, Error>) -> Void)
}

/// Протокол для Router модуля TaskDetail
protocol TaskDetailRouterInterface: AnyObject {
    var viewController: UIViewController? { get set }
    
    func navigateBack()
}

/// Протокол для Builder модуля TaskDetail
protocol TaskDetailModuleBuilderInterface {
    /// Создать модуль TaskDetail на основе существующей задачи
    static func build(with task: Task?) -> UIViewController
}

// MARK: - CreateTask Module Protocols

/// Протокол для Presenter модуля CreateTask
protocol CreateTaskPresenterInterface: BasePresenterInterface {
    /// Обработка создания задачи
    func didTapCreateTask(title: String, description: String?, isCompleted: Bool)
    
    /// Обработка отмены создания
    func didTapCancel()
}

/// Протокол для View модуля CreateTask
protocol CreateTaskViewInterface: BaseViewInterface {
    /// Ссылка на presenter с конкретным типом
    var createTaskPresenter: CreateTaskPresenterInterface? { get set }
    
    /// Закрытие экрана после создания задачи
    func closeScreen()
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