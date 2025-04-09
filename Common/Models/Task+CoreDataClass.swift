import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {
    @objc override public func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Устанавливаем начальные значения на основном потоке
        DispatchQueue.main.async {
            // Создаем уникальный идентификатор
            self.id = UUID().uuidString
            
            // Устанавливаем дату создания
            self.createdAt = Date()
            
            // Устанавливаем ID пользователя (в реальном приложении должно быть из сессии)
            self.userId = 1
            
            // По умолчанию задача не выполнена
            self.isCompleted = false
            
            // Пустые значения для заголовка и описания
            self.taskDescription = ""
        }
    }
    
    // Переопределяем сеттер для отслеживания изменений isCompleted и title
    @objc public override func willChangeValue(forKey key: String) {
        if key == "isCompleted" {
            print("DEBUG: Task - willChangeValue для isCompleted: текущее значение = \(self.isCompleted)")
        } else if key == "title" {
            print("DEBUG: Task - willChangeValue для title: текущее значение = '\(self.title ?? "nil")'")
        }
        super.willChangeValue(forKey: key)
    }
    
    @objc public override func didChangeValue(forKey key: String) {
        if key == "isCompleted" {
            print("DEBUG: Task - didChangeValue для isCompleted: новое значение = \(self.isCompleted)")
        } else if key == "title" {
            print("DEBUG: Task - didChangeValue для title: новое значение = '\(self.title ?? "nil")'")
        }
        super.didChangeValue(forKey: key)
    }
} 