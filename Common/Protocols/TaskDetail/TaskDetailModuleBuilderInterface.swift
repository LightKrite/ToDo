import UIKit
import CoreData

/// Протокол для Builder модуля TaskDetail
protocol TaskDetailModuleBuilderInterface {
    /// Создать модуль TaskDetail на основе существующей задачи
    static func build(with task: Task?) -> UIViewController
} 