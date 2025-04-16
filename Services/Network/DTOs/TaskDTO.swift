import Foundation

/// DTO для передачи данных задачи
struct TaskDTO: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case todo
        case completed
        case userId
    }
} 