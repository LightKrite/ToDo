import Foundation
import CoreData

final class CoreDataStack {
    
    // MARK: - Singleton
    static let shared = CoreDataStack()
    
    private init() {}
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Ошибка загрузки хранилища: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Ошибка сохранения контекста: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - CRUD операции
    
    // Создание новой задачи
    func createTask(id: String, title: String, description: String?, isCompleted: Bool, completionHandler: @escaping (Task?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        
        backgroundContext.perform {
            let task = Task(context: backgroundContext)
            task.id = id
            task.title = title
            task.taskDescription = description
            task.createdAt = Date()
            task.isCompleted = isCompleted
            
            do {
                try backgroundContext.save()
                
                // Синхронизация с main context
                self.context.perform {
                    let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                    
                    do {
                        let tasks = try self.context.fetch(fetchRequest)
                        completionHandler(tasks.first)
                    } catch {
                        completionHandler(nil)
                    }
                }
            } catch {
                print("Ошибка создания задачи: \(error)")
                completionHandler(nil)
            }
        }
    }
    
    // Получение всех задач
    func fetchAllTasks(completionHandler: @escaping ([Task]) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            do {
                let tasks = try backgroundContext.fetch(fetchRequest)
                
                // Переключаемся на главный контекст
                self.context.perform {
                    let mainContextTasks = tasks.compactMap { task -> Task? in
                        guard let id = task.id else { return nil }
                        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                        
                        do {
                            let results = try self.context.fetch(fetchRequest)
                            return results.first
                        } catch {
                            return nil
                        }
                    }
                    
                    completionHandler(mainContextTasks)
                }
            } catch {
                print("Ошибка при получении задач: \(error)")
                completionHandler([])
            }
        }
    }
    
    // Поиск задач по строке
    func searchTasks(with query: String, completionHandler: @escaping ([Task]) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@", query, query)
            
            do {
                let tasks = try backgroundContext.fetch(fetchRequest)
                
                // Переключаемся на главный контекст
                self.context.perform {
                    let mainContextTasks = tasks.compactMap { task -> Task? in
                        guard let id = task.id else { return nil }
                        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                        
                        do {
                            let results = try self.context.fetch(fetchRequest)
                            return results.first
                        } catch {
                            return nil
                        }
                    }
                    
                    completionHandler(mainContextTasks)
                }
            } catch {
                print("Ошибка при поиске задач: \(error)")
                completionHandler([])
            }
        }
    }
    
    // Обновление задачи
    func updateTask(task: Task, title: String, description: String?, isCompleted: Bool, completionHandler: @escaping (Bool) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        
        guard let id = task.id else {
            completionHandler(false)
            return
        }
        
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let tasks = try backgroundContext.fetch(fetchRequest)
                
                if let taskToUpdate = tasks.first {
                    taskToUpdate.title = title
                    taskToUpdate.taskDescription = description
                    taskToUpdate.isCompleted = isCompleted
                    
                    try backgroundContext.save()
                    
                    // Обновляем в главном контексте
                    self.context.perform {
                        task.title = title
                        task.taskDescription = description
                        task.isCompleted = isCompleted
                        
                        do {
                            try self.context.save()
                            completionHandler(true)
                        } catch {
                            completionHandler(false)
                        }
                    }
                } else {
                    completionHandler(false)
                }
            } catch {
                print("Ошибка при обновлении задачи: \(error)")
                completionHandler(false)
            }
        }
    }
    
    // Удаление задачи
    func deleteTask(task: Task, completionHandler: @escaping (Bool) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        
        guard let id = task.id else {
            completionHandler(false)
            return
        }
        
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let tasks = try backgroundContext.fetch(fetchRequest)
                
                if let taskToDelete = tasks.first {
                    backgroundContext.delete(taskToDelete)
                    try backgroundContext.save()
                    
                    // Удаляем в главном контексте
                    self.context.perform {
                        self.context.delete(task)
                        
                        do {
                            try self.context.save()
                            completionHandler(true)
                        } catch {
                            completionHandler(false)
                        }
                    }
                } else {
                    completionHandler(false)
                }
            } catch {
                print("Ошибка при удалении задачи: \(error)")
                completionHandler(false)
            }
        }
    }
    
    // Удаление всех задач (для тестирования)
    func deleteAllTasks(completionHandler: @escaping (Bool) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try backgroundContext.execute(deleteRequest)
                try backgroundContext.save()
                
                // Уведомляем главный контекст
                self.context.perform {
                    self.context.reset()
                    completionHandler(true)
                }
            } catch {
                print("Ошибка при удалении всех задач: \(error)")
                completionHandler(false)
            }
        }
    }
} 