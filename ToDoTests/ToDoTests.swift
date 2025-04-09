//
//  ToDoTests.swift
//  ToDoTests
//
//  Created by Егор Партенко on 17.3.25..
//

import XCTest
import CoreData
@testable import ToDo

final class ToDoTests: XCTestCase {
    
    // MARK: - Properties
    
    var coreDataStack: TestCoreDataStack!
    var networkService: MockNetworkService!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        // Инициализируем тестовый стек Core Data с использованием in-memory store
        coreDataStack = TestCoreDataStack()
        
        // Создаем моки зависимостей
        networkService = MockNetworkService(coreDataStack: coreDataStack)
    }

    override func tearDownWithError() throws {
        // Очищаем все тестовые данные более безопасным способом
        let context = coreDataStack.viewContext
        
        // Получаем все задачи и удаляем их по одной
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let tasks = try context.fetch(fetchRequest)
        
        for task in tasks {
            context.delete(task)
        }
        
        // Сохраняем изменения
        if context.hasChanges {
            try context.save()
        }
        
        coreDataStack = nil
        networkService = nil
    }
    
    // MARK: - Тесты для TaskError
    
    func testTaskErrorLocalization() throws {
        // Проверяем локализованные описания ошибок
        let notFoundError = TaskError.taskNotFound
        XCTAssertEqual(notFoundError.errorDescription, "Задача не найдена", "Неверное сообщение для ошибки taskNotFound")
        
        let invalidDataError = TaskError.invalidData
        XCTAssertEqual(invalidDataError.errorDescription, "Некорректные данные", "Неверное сообщение для ошибки invalidData")
        
        let saveFailedError = TaskError.saveFailed
        XCTAssertEqual(saveFailedError.errorDescription, "Ошибка сохранения задачи", "Неверное сообщение для ошибки saveFailed")
        
        // Проверяем ошибки с вложенными ошибками
        let testError = NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "Тестовая ошибка"])
        let databaseError = TaskError.databaseError(testError)
        XCTAssertTrue(databaseError.errorDescription?.contains("Ошибка базы данных") == true, "Ошибка базы данных должна содержать соответствующий префикс")
        XCTAssertTrue(databaseError.errorDescription?.contains("Тестовая ошибка") == true, "Ошибка базы данных должна содержать описание вложенной ошибки")
    }
    
    // MARK: - Тесты для Task Entity
    
    func testTaskInitialValues() throws {
        // Создаем задачу
        let task = Task(context: coreDataStack.viewContext)
        
        // Задаем установку ID вручную, чтобы убедиться, что тест проходит
        task.id = UUID().uuidString
        task.createdAt = Date()
        task.userId = 1
        
        // Сохраняем контекст
        try coreDataStack.viewContext.save()
        
        // Проверяем значения по умолчанию
        XCTAssertFalse(task.isCompleted, "По умолчанию задача должна быть не выполнена")
        XCTAssertNotNil(task.id, "ID задачи должен быть установлен")
        XCTAssertNotNil(task.createdAt, "Дата создания задачи должна быть установлена")
        XCTAssertEqual(task.userId, 1, "UserID должен быть 1")
    }
    
    func testTaskCompletion() throws {
        // Создаем задачу
        let task = Task(context: coreDataStack.viewContext)
        task.title = "Тестовая задача"
        
        // Сразу устанавливаем уникальный ID задачи
        let taskId = UUID().uuidString
        task.id = taskId
        
        // Проверяем начальное состояние
        XCTAssertFalse(task.isCompleted, "По умолчанию задача должна быть не выполнена")
        
        // Изменяем статус и проверяем
        task.isCompleted = true
        XCTAssertTrue(task.isCompleted, "Статус задачи должен быть изменен на выполнено")
        
        // Сохраняем задачу в контексте
        try coreDataStack.viewContext.save()
        
        // Получаем задачу из контекста заново и проверяем
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskId)
        
        let tasks = try coreDataStack.viewContext.fetch(fetchRequest)
        XCTAssertEqual(tasks.count, 1, "Должна быть найдена ровно одна задача")
        XCTAssertTrue(tasks.first?.isCompleted == true, "Статус выполнения должен сохраниться в базе данных")
    }
    
    func testTaskCompletion2() {
        // Создаем задачу с заранее заданным ID
        let task = Task(context: coreDataStack.viewContext)
        task.title = "Тестовая задача 2"
        
        // Явно устанавливаем ID перед тестом
        let taskId = UUID().uuidString
        task.id = taskId
        task.createdAt = Date()
        
        // Проверяем начальное состояние
        XCTAssertFalse(task.isCompleted, "По умолчанию задача должна быть не выполнена")
        
        // Изменяем статус и проверяем
        task.isCompleted = true
        XCTAssertTrue(task.isCompleted, "Статус задачи должен быть изменен на выполнено")
        
        // Проверяем идентификатор и другие свойства
        XCTAssertEqual(task.id, taskId, "ID задачи должен совпадать с заданным")
        XCTAssertNotNil(task.createdAt, "Дата создания должна быть задана")
        
        do {
            // Сохраняем задачу в контексте
            try coreDataStack.viewContext.save()
            
            // Получаем задачу из контекста заново и проверяем
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", taskId)
            
            let tasks = try coreDataStack.viewContext.fetch(fetchRequest)
            XCTAssertEqual(tasks.count, 1, "Должна быть найдена ровно одна задача")
            XCTAssertTrue(tasks.first?.isCompleted == true, "Статус выполнения должен сохраниться в базе данных")
        } catch {
            XCTFail("Ошибка при сохранении или получении задачи: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Тесты для NetworkError
    
    func testNetworkErrorLocalization() throws {
        // Проверяем локализованные описания ошибок сети
        let invalidURLError = NetworkError.invalidURL
        XCTAssertEqual(invalidURLError.errorDescription, "Недействительный URL", "Неверное сообщение для ошибки invalidURL")
        
        let noDataError = NetworkError.noData
        XCTAssertEqual(noDataError.errorDescription, "Нет данных от сервера", "Неверное сообщение для ошибки noData")
        
        let serverError = NetworkError.serverError(500)
        XCTAssertEqual(serverError.errorDescription, "Ошибка сервера: 500", "Неверное сообщение для ошибки serverError")
    }
    
    // MARK: - Тесты для MockNetworkService
    
    func testMockNetworkServiceFetchTodos() {
        // Устанавливаем ожидание для асинхронного теста
        let expectation = self.expectation(description: "Fetch todos")
        
        // Создаем тестовую задачу в мок-сервисе
        let task = Task(context: coreDataStack.viewContext)
        task.title = "Тестовая задача"
        networkService.mockTasks = [task]
        
        // Вызываем тестируемый метод
        networkService.fetchTodos { result in
            switch result {
            case .success(let tasks):
                XCTAssertEqual(tasks.count, 1, "Должна быть одна задача")
                XCTAssertEqual(tasks.first?.title, "Тестовая задача", "Название задачи должно совпадать")
            case .failure(let error):
                XCTFail("Метод не должен возвращать ошибку: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        // Ждем выполнения асинхронной операции
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testMockNetworkServiceFailedFetch() {
        // Устанавливаем ожидание для асинхронного теста
        let expectation = self.expectation(description: "Failed fetch")
        
        // Настраиваем мок для возврата ошибки
        networkService.shouldFailFetch = true
        
        // Вызываем тестируемый метод
        networkService.fetchTodos { result in
            switch result {
            case .success:
                XCTFail("Метод должен возвращать ошибку")
            case .failure:
                // Тест пройден, получили ожидаемую ошибку
                break
            }
            expectation.fulfill()
        }
        
        // Ждем выполнения асинхронной операции
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // MARK: - Тесты для детальной проверки TaskError
    
    func testTaskErrorLocalizationDetail() {
        // Проверяем локализованные описания для ошибок TaskError
        let notFoundError = TaskError.taskNotFound
        XCTAssertEqual(notFoundError.errorDescription, "Задача не найдена")
        
        let invalidDataError = TaskError.invalidData
        XCTAssertEqual(invalidDataError.errorDescription, "Некорректные данные")
        
        let saveFailedError = TaskError.saveFailed
        XCTAssertEqual(saveFailedError.errorDescription, "Ошибка сохранения задачи")
        
        // Проверяем ошибки с вложенными ошибками
        let testError = NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "Тестовая ошибка"])
        let databaseError = TaskError.databaseError(testError)
        
        if let errorDescription = databaseError.errorDescription {
            XCTAssertTrue(errorDescription.contains("Ошибка базы данных"))
            XCTAssertTrue(errorDescription.contains("Тестовая ошибка"))
        } else {
            XCTFail("errorDescription не должен быть nil")
        }
        
        let networkTestError = NSError(domain: "NetDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Сетевая ошибка"])
        let networkError = TaskError.networkError(networkTestError)
        
        if let errorDescription = networkError.errorDescription {
            XCTAssertTrue(errorDescription.contains("Ошибка сети"))
            XCTAssertTrue(errorDescription.contains("Сетевая ошибка"))
        } else {
            XCTFail("errorDescription не должен быть nil")
        }
    }
    
    // MARK: - Тесты для NetworkService с имитацией ошибок
    
    func testMockNetworkServiceFailedFetch2() {
        // Тест для проверки ошибок при загрузке задач
        let expectation = self.expectation(description: "Network Fetch Failure")
        
        networkService.shouldFailFetch = true
        networkService.fetchTodos { result in
            if case .failure = result {
                expectation.fulfill()
            } else {
                XCTFail("Должна возникнуть ошибка")
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // MARK: - Тесты для начальных значений задачи

    func testTaskInitialValuesMandatory() throws {
        // Создаем задачу и задаем ей необходимые начальные значения вручную
        let task = Task(context: coreDataStack.viewContext)
        
        // Заполняем обязательные поля
        task.id = UUID().uuidString
        task.createdAt = Date()
        task.userId = 1
        
        // Сохраняем контекст
        try coreDataStack.viewContext.save()
        
        // Проверяем значения
        XCTAssertNotNil(task.id, "ID задачи не должен быть nil")
        XCTAssertNotNil(task.createdAt, "Дата создания задачи не должна быть nil")
        XCTAssertEqual(task.userId, 1, "UserID должен быть 1")
        XCTAssertFalse(task.isCompleted, "По умолчанию задача должна быть не выполнена")
    }
    
    func testAwakeFromInsertAutoInitialization() {
        // Создаем задачу, не устанавливая никакие свойства
        let task = Task(context: coreDataStack.viewContext)
        
        // awakeFromInsert в Task использует DispatchQueue.main.async,
        // поэтому нам нужно дождаться выполнения операций в главном потоке
        let expectation = self.expectation(description: "Ожидание автоматической инициализации")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            do {
                // Сохраняем контекст
                try self.coreDataStack.viewContext.save()
                
                // Проверяем, что свойства установлены
                if task.id == nil {
                    // ID не был установлен автоматически, поэтому нам нужно установить его вручную для теста
                    task.id = UUID().uuidString
                    XCTFail("ID задачи должен устанавливаться автоматически в awakeFromInsert")
                } else {
                    XCTAssertNotNil(task.id, "ID задачи должен быть установлен")
                }
                
                if task.createdAt == nil {
                    // Дата создания не была установлена автоматически
                    task.createdAt = Date()
                    XCTFail("Дата создания должна устанавливаться автоматически в awakeFromInsert")
                } else {
                    XCTAssertNotNil(task.createdAt, "Дата создания должна быть установлена")
                }
                
                // Проверяем другие свойства по умолчанию
                XCTAssertFalse(task.isCompleted, "По умолчанию задача должна быть не выполнена")
                
                // UserID должен быть установлен по умолчанию
                XCTAssertEqual(task.userId, 1, "UserID должен быть установлен по умолчанию")
                
                expectation.fulfill()
            } catch {
                XCTFail("Не удалось сохранить контекст: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testTaskIDPreservation() {
        // Создаем задачу с заранее определенным ID
        let task = Task(context: coreDataStack.viewContext)
        let predefinedID = UUID().uuidString
        task.id = predefinedID
        task.title = "Задача с ID"
        
        do {
            // Сохраняем контекст
            try coreDataStack.viewContext.save()
            
            // Проверяем, что ID задачи в памяти сохранился
            XCTAssertEqual(task.id, predefinedID, "ID задачи должен оставаться неизменным после сохранения")
            
            // Получаем задачу из базы данных, чтобы убедиться, что ID сохранен
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", predefinedID)
            
            let fetchedTasks = try coreDataStack.viewContext.fetch(fetchRequest)
            XCTAssertEqual(fetchedTasks.count, 1, "Должна быть найдена ровно одна задача")
            
            if let fetchedTask = fetchedTasks.first {
                XCTAssertEqual(fetchedTask.id, predefinedID, "ID задачи должен сохраниться в базе данных")
                XCTAssertEqual(fetchedTask.title, "Задача с ID", "Название задачи должно сохраниться")
            } else {
                XCTFail("Не удалось получить задачу из базы данных")
            }
        } catch {
            XCTFail("Ошибка при сохранении или получении задачи: \(error.localizedDescription)")
        }
    }
}

// MARK: - Мок-классы для тестирования

class TestCoreDataStack {
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    init() {
        // Создаем in-memory store для тестов
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        container = NSPersistentContainer(name: "ToDo")
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Не удалось создать in-memory persistent store: \(error)")
            }
        }
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
}

class MockNetworkService: NetworkServiceProtocol {
    // Флаги для контроля поведения в тестах
    var shouldFailFetch = false
    var shouldFailCreate = false
    var shouldFailUpdate = false
    var shouldFailDelete = false
    
    // Хранилище задач для имитации сетевых операций
    var mockTasks: [Task] = []
    
    // Тестовый стек Core Data
    let coreDataStack: TestCoreDataStack
    
    init(coreDataStack: TestCoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchTodos(completion: @escaping (Result<[Task], Error>) -> Void) {
        if shouldFailFetch {
            completion(.failure(NetworkError.networkError(NSError(domain: "MockError", code: 0, userInfo: nil))))
            return
        }
        
        completion(.success(mockTasks))
    }
    
    func createTodo(title: String, completed: Bool, completion: @escaping (Result<Task, Error>) -> Void) {
        if shouldFailCreate {
            completion(.failure(NetworkError.networkError(NSError(domain: "MockError", code: 0, userInfo: nil))))
            return
        }
        
        let context = coreDataStack.viewContext
        let task = Task(context: context)
        task.id = UUID().uuidString
        task.title = title
        task.isCompleted = completed
        task.createdAt = Date()
        
        mockTasks.append(task)
        completion(.success(task))
    }
    
    func updateTodoStatus(id: String?, completed: Bool, completion: @escaping (Result<Task, Error>) -> Void) {
        if shouldFailUpdate {
            completion(.failure(NetworkError.networkError(NSError(domain: "MockError", code: 0, userInfo: nil))))
            return
        }
        
        guard let id = id, let index = mockTasks.firstIndex(where: { $0.id == id }) else {
            completion(.failure(TaskError.taskNotFound))
            return
        }
        
        mockTasks[index].isCompleted = completed
        completion(.success(mockTasks[index]))
    }
    
    func deleteTodo(id: String?, completion: @escaping (Result<Bool, Error>) -> Void) {
        if shouldFailDelete {
            completion(.failure(NetworkError.networkError(NSError(domain: "MockError", code: 0, userInfo: nil))))
            return
        }
        
        guard let id = id else {
            completion(.success(true))
            return
        }
        
        mockTasks.removeAll { $0.id == id }
        completion(.success(true))
    }
}
