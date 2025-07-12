import Foundation

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