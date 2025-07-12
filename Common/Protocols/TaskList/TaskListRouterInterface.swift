import UIKit
import CoreData

/// Протокол для Router модуля TaskList
protocol TaskListRouterInterface: AnyObject {
    var viewController: UIViewController? { get set }
    
    func navigateToTaskDetail(with task: Task)
    func navigateToCreateTask()
} 