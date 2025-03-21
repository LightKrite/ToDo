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
        let createTaskVC = buildCreateTaskModule()
        
        let navigationController = UINavigationController(rootViewController: createTaskVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        viewController?.present(navigationController, animated: true)
    }
    
    // MARK: - Private modules builder methods
    private func buildTaskDetailModule(with task: Task) -> UIViewController {
        // В реальном коде здесь использовался бы билдер модуля TaskDetail
        // Заглушка для демонстрации
        let vc = UIViewController()
        vc.title = task.title
        vc.view.backgroundColor = .black
        return vc
    }
    
    private func buildCreateTaskModule() -> UIViewController {
        // В реальном коде здесь использовался бы билдер модуля CreateTask
        // Заглушка для демонстрации
        let vc = UIViewController()
        vc.title = "Новая задача"
        vc.view.backgroundColor = .black
        return vc
    }
} 