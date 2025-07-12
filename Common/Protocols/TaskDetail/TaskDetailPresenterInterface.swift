import Foundation

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