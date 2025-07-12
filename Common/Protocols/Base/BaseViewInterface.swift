import UIKit

/// Базовый протокол для всех View в архитектуре VIPER
protocol BaseViewInterface: AnyObject {
    /// Отображение индикатора загрузки
    func showLoading()
    
    /// Скрытие индикатора загрузки
    func hideLoading()
    
    /// Отображение сообщения об ошибке
    func showError(_ message: String)
    
    /// Отображение всплывающего сообщения
    func showMessage(_ message: String)
}

// MARK: - Реализация по умолчанию

extension BaseViewInterface where Self: UIViewController {
    func showLoading() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.tag = 999
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        if let activityIndicator = view.viewWithTag(999) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
        view.isUserInteractionEnabled = true
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Сообщение", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 