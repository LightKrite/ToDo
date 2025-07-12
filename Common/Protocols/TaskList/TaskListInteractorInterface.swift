import Foundation
import CoreData

/// Протокол для Interactor модуля TaskList
protocol TaskListInteractorInterface: AnyObject {
    var presenter: TaskListPresenterInterface? { get set }
    var dataManager: DataManagerProtocol { get }
    
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void)
    func fetchInitialData(completion: @escaping (Result<[Task], Error>) -> Void)
    func searchTasks(with query: String, completion: @escaping (Result<[Task], Error>) -> Void)
    func updateTask(task: Task, completion: @escaping (Result<Task, Error>) -> Void)
    func deleteTask(task: Task, completion: @escaping (Result<Bool, Error>) -> Void)
} 