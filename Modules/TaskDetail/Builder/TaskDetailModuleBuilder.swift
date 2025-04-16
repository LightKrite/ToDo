import UIKit

final class TaskDetailModuleBuilder: TaskDetailModuleBuilderInterface {
    
    static func build(with task: Task?) -> UIViewController {
        guard let task = task else {
            // Если задача не передана, возвращаем пустой контроллер или можно добавить сообщение об ошибке
            let emptyVC = UIViewController()
            emptyVC.view.backgroundColor = .white
            let label = UILabel()
            label.text = "Задача не найдена"
            label.textAlignment = .center
            label.frame = emptyVC.view.bounds
            emptyVC.view.addSubview(label)
            return emptyVC
        }
        
        // Создаем зависимости
        let coreDataStack = CoreDataStack()
        let logger = Logger.shared
        let networkService = NetworkService()
        let dataManager = DataManager(
            coreDataStack: coreDataStack,
            networkService: networkService,
            logger: logger
        )
        
        let viewController = TaskDetailViewController()
        let interactor = TaskDetailInteractor(task: task, dataManager: dataManager)
        let presenter = TaskDetailPresenter(task: task)
        let router = TaskDetailRouter(viewController: viewController)
        
        viewController.taskDetailPresenter = presenter
        presenter.view = viewController
        presenter.interactor = interactor
        presenter.router = router
        
        return viewController
    }
} 