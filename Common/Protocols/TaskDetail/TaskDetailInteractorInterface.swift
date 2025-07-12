import Foundation
import CoreData

/// Протокол для Interactor модуля TaskDetail
protocol TaskDetailInteractorInterface: AnyObject {
    var presenter: TaskDetailPresenterInterface? { get set }
    var task: Task { get }
    var dataManager: DataManagerProtocol { get }
    
    func getTask(completion: @escaping (Result<Task, Error>) -> Void)
    func updateTask(title: String, description: String?, isCompleted: Bool, completion: @escaping (Result<Task, Error>) -> Void)
    func deleteTask(_ task: Task, completion: @escaping (Result<Bool, Error>) -> Void)
} 