import UIKit

final class TaskListRouter: TaskListRouterInterface {
    // MARK: - VIPER
    weak var viewController: UIViewController?
    
    // MARK: - TaskListRouterInterface
    func navigateToTaskDetail(with task: Task) {
        let taskDetailVC = buildTaskDetailModule(with: task)
        
        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(taskDetailVC, animated: true)
        } else {
            viewController?.present(taskDetailVC, animated: true)
        }
    }
    
    func navigateToCreateTask() {
        let createTaskVC = buildTaskDetailModule(isNewTask: true)
        
        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(createTaskVC, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: createTaskVC)
            navigationController.modalPresentationStyle = .fullScreen
            viewController?.present(navigationController, animated: true)
        }
    }
    
    // MARK: - Private modules builder methods
    private func buildTaskDetailModule(with task: Task? = nil, isNewTask: Bool = false) -> UIViewController {
        // Создаем пустую задачу с текущей датой, если это новая задача
        let context = CoreDataStack.shared.mainContext
        let taskToUse: Task
        
        if isNewTask {
            taskToUse = Task(context: context)
            taskToUse.id = UUID().uuidString
            taskToUse.title = ""
            taskToUse.taskDescription = ""
            taskToUse.isCompleted = false
            taskToUse.createdAt = Date()
            taskToUse.userId = 1 // По умолчанию для демонстрации
            print("DEBUG: TaskListRouter - создан экран для новой задачи")
        } else if let existingTask = task {
            taskToUse = existingTask
            print("DEBUG: TaskListRouter - создан экран для существующей задачи: '\(taskToUse.title ?? "nil")', id: \(taskToUse.id ?? "nil")")
        } else {
            // Если что-то пошло не так, создаем пустую задачу
            taskToUse = Task(context: context)
            taskToUse.id = UUID().uuidString
            taskToUse.title = ""
            taskToUse.createdAt = Date()
            print("DEBUG: TaskListRouter - создан запасной экран с пустой задачей")
        }
        
        // Создаем компоненты VIPER
        let taskDetailVC = TaskDetailViewController()
        let presenter = TaskDetailPresenter(task: taskToUse)
        let interactor = TaskDetailInteractor(task: taskToUse)
        let router = TaskDetailRouter(viewController: taskDetailVC)
        
        // Устанавливаем зависимости
        taskDetailVC.taskDetailPresenter = presenter
        presenter.view = taskDetailVC
        presenter.interactor = interactor
        presenter.router = router
        
        // Если это новая задача, сразу переходим в режим редактирования
        if isNewTask {
            DispatchQueue.main.async {
                taskDetailVC.enterEditMode()
            }
        }
        
        // КРИТИЧНО: убеждаемся, что экран обернут в навигационный контроллер, если его нет
        if viewController?.navigationController == nil {
            print("DEBUG: TaskListRouter - Создаю новый UINavigationController для TaskDetailVC")
            let navigationController = UINavigationController(rootViewController: taskDetailVC)
            navigationController.modalPresentationStyle = .fullScreen
            return navigationController
        }
        
        return taskDetailVC
    }
} 