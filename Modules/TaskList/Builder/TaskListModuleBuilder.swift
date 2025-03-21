import UIKit

final class TaskListModuleBuilder: ModuleBuilderInterface {
    static func build(with parameters: [String: Any] = [:]) -> UIViewController {
        // Создание компонентов VIPER
        let view = TaskListViewController()
        let interactor = TaskListInteractor()
        let router = TaskListRouter()
        let presenter = TaskListPresenter(view: view, interactor: interactor, router: router)
        
        // Настройка зависимостей
        view.taskListPresenter = presenter
        router.viewController = view
        
        // Инициализация интерактора
        interactor.initialize()
        
        return view
    }
} 