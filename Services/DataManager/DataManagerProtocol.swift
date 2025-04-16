import Foundation
import CoreData

/// Протокол для управления данными задач
protocol DataManagerProtocol {
    /// Загружает начальный список задач
    /// - Parameter completion: Замыкание с результатом операции
    func fetchInitialTasks(completion: @escaping (Result<[Task], Error>) -> Void)
    
    /// Создает новую задачу
    /// - Parameters:
    ///   - title: Заголовок задачи
    ///   - description: Описание задачи
    ///   - isCompleted: Статус выполнения задачи
    ///   - completion: Замыкание с результатом операции
    func createTask(title: String, description: String, isCompleted: Bool, completion: @escaping (Result<Task, Error>) -> Void)
    
    /// Получает список всех задач
    /// - Parameter completion: Замыкание с результатом операции
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void)
    
    /// Выполняет поиск задач по запросу
    /// - Parameters:
    ///   - query: Поисковый запрос
    ///   - completion: Замыкание с результатом операции
    func searchTasks(with query: String, completion: @escaping (Result<[Task], Error>) -> Void)
    
    /// Обновляет существующую задачу
    /// - Parameters:
    ///   - task: Задача для обновления
    ///   - completion: Замыкание с результатом операции
    func updateTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void)
    
    /// Удаляет задачу
    /// - Parameters:
    ///   - task: Задача для удаления
    ///   - completion: Замыкание с результатом операции
    func deleteTask(_ task: Task, completion: @escaping (Result<Bool, Error>) -> Void)

    /// Сохраняет все изменения в основном контексте
    /// - Throws: Ошибку, если сохранение не удалось
    func saveContext() throws
} 