import Foundation

/// Структура ответа API с задачами
struct TodosResponse: Codable {
    let todos: [TaskDTO]
    let total: Int
    let skip: Int
    let limit: Int
} 