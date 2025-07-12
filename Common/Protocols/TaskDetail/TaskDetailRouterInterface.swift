import UIKit

/// Протокол для Router модуля TaskDetail
protocol TaskDetailRouterInterface: AnyObject {
    var viewController: UIViewController? { get set }
    
    func navigateBack()
} 