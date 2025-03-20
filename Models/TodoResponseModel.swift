import Foundation

// MARK: - TodoResponseModel
struct TodoResponseModel: Decodable {
    let todos: [TodoModel]
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - TodoModel
struct TodoModel: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
    
    // Преобразование в CoreData Task
    func asCoreDataTask() -> (id: String, title: String, description: String?, isCompleted: Bool) {
        return (
            id: String(id),
            title: todo,
            description: nil, // API не предоставляет описание
            isCompleted: completed
        )
    }
} 