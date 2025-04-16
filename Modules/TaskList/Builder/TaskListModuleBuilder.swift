import UIKit

final class TaskListModuleBuilder: ModuleBuilderInterface {
    static func build(with parameters: [String: Any] = [:]) -> UIViewController {
        // Создаем зависимости
        let coreDataStack = CoreDataStack()
        let logger = Logger.shared
        let networkService = NetworkService()
        let dataManager = DataManager(
            coreDataStack: coreDataStack,
            networkService: networkService,
            logger: logger
        )
        
        // Создание компонентов VIPER
        let view = TaskListViewController()
        let interactor = TaskListInteractor(
            dataManager: dataManager,
            logger: logger
        )
        let router = TaskListRouter()
        let presenter = TaskListPresenter()
        
        // Настройка зависимостей
        presenter.view = view
        presenter.interactor = interactor 
        presenter.router = router
        view.taskListPresenter = presenter
        router.viewController = view
        interactor.presenter = presenter
        
        // Инициализация интерактора
        interactor.initialize()
        
        return view
    }
} 