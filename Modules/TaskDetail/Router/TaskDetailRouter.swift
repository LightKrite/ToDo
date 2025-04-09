import UIKit

final class TaskDetailRouter: TaskDetailRouterInterface {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Initialization
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - TaskDetailRouterInterface
    func navigateBack() {
        if let navigationController = viewController?.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            viewController?.dismiss(animated: true)
        }
    }
} 