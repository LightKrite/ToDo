import Foundation
import CoreData

/// Протокол для работы с сетевым сервисом
protocol NetworkServiceProtocol {
    /// Загружает список задач с сервера
    /// - Parameter completion: Замыкание для обработки результата запроса
    func fetchTodos(completion: @escaping (Result<[Task], Error>) -> Void)
    
    /// Создает новую задачу на сервере
    /// - Parameters:
    ///   - title: Заголовок задачи
    ///   - completed: Статус выполнения задачи
    ///   - completion: Замыкание для обработки результата запроса
    func createTodo(title: String, completed: Bool, completion: @escaping (Result<Task, Error>) -> Void)
    
    /// Обновляет статус выполнения задачи на сервере
    /// - Parameters:
    ///   - id: Идентификатор задачи
    ///   - completed: Новый статус выполнения задачи
    ///   - completion: Замыкание для обработки результата запроса
    func updateTodoStatus(id: String?, completed: Bool, completion: @escaping (Result<Task, Error>) -> Void)
    
    /// Удаляет задачу с сервера
    /// - Parameters:
    ///   - id: Идентификатор задачи для удаления
    ///   - completion: Замыкание для обработки результата запроса
    func deleteTodo(id: String?, completion: @escaping (Result<Bool, Error>) -> Void)
} 