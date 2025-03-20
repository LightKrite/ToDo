import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Некорректный URL"
        case .noData:
            return "Нет данных от сервера"
        case .decodingError:
            return "Ошибка декодирования данных"
        case .serverError(let statusCode):
            return "Ошибка сервера: \(statusCode)"
        case .unknown(let error):
            return "Неизвестная ошибка: \(error.localizedDescription)"
        }
    }
}

final class NetworkService {
    
    // MARK: - Singleton
    static let shared = NetworkService()
    
    private init() {}
    
    // MARK: - Constants
    private let baseURL = "https://dummyjson.com"
    
    // MARK: - Public Methods
    
    /// Загрузка списка задач
    func fetchTodos(completion: @escaping (Result<[TodoModel], NetworkError>) -> Void) {
        // Выполняем в глобальной очереди
        DispatchQueue.global(qos: .userInitiated).async {
            let urlString = "\(self.baseURL)/todos"
            
            guard let url = URL(string: urlString) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidURL))
                }
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(.unknown(error)))
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                // Проверяем статус ответа
                if !(200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let todoResponse = try decoder.decode(TodoResponseModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(todoResponse.todos))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            }
            
            task.resume()
        }
    }
    
    /// Добавление задачи на сервер (для демонстрации, так как API может не поддерживать это)
    func createTodo(title: String, completed: Bool, completion: @escaping (Result<TodoModel, NetworkError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let urlString = "\(self.baseURL)/todos/add"
            
            guard let url = URL(string: urlString) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidURL))
                }
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let parameters: [String: Any] = [
                "todo": title,
                "completed": completed,
                "userId": 1 // Используем фиксированный userId
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.unknown(error)))
                }
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(.unknown(error)))
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                // Проверяем статус ответа
                if !(200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let todoModel = try decoder.decode(TodoModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(todoModel))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            }
            
            task.resume()
        }
    }
    
    /// Обновление статуса задачи (для демонстрации)
    func updateTodoStatus(id: Int, completed: Bool, completion: @escaping (Result<TodoModel, NetworkError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let urlString = "\(self.baseURL)/todos/\(id)"
            
            guard let url = URL(string: urlString) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidURL))
                }
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let parameters: [String: Any] = [
                "completed": completed
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.unknown(error)))
                }
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(.unknown(error)))
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                // Проверяем статус ответа
                if !(200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let todoModel = try decoder.decode(TodoModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(todoModel))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            }
            
            task.resume()
        }
    }
    
    /// Удаление задачи (для демонстрации)
    func deleteTodo(id: Int, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let urlString = "\(self.baseURL)/todos/\(id)"
            
            guard let url = URL(string: urlString) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidURL))
                }
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(.unknown(error)))
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                // Проверяем статус ответа
                if !(200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            }
            
            task.resume()
        }
    }
} 