import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Создаем окно
        window = UIWindow(windowScene: windowScene)
        
        // Создаем корневой контроллер с помощью модульного билдера TaskList
        let taskListViewController = TaskListModuleBuilder.build()
        
        // Оборачиваем в навигационный контроллер
        let navigationController = UINavigationController(rootViewController: taskListViewController)
        navigationController.navigationBar.isHidden = true // Скрываем навбар, так как в дизайне его нет
        
        // Настраиваем внешний вид системных элементов
        configureAppearance()
        
        // Устанавливаем корневой контроллер
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Получаем CoreDataStack из корневого контроллера
        guard let navigationController = window?.rootViewController as? UINavigationController,
              let taskListVC = navigationController.viewControllers.first as? TaskListViewController,
              let presenter = taskListVC.taskListPresenter,
              let interactor = presenter.interactor,
              let dataManager = interactor.dataManager as? DataManager else {
            print("Не удалось получить доступ к CoreDataStack")
            return
        }
        
        // Сохраняем контекст Core Data при уходе в фон
        do {
            try dataManager.saveContext()
        } catch {
            print("Ошибка при сохранении контекста CoreData: \(error.localizedDescription)")
        }
    }
    
    // MARK: - UI Appearance Configuration
    private func configureAppearance() {
        // Настройка внешнего вида UINavigationBar
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = .black
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().isTranslucent = false
        }
        
        // Настройка внешнего вида UITabBar если понадобится
        UITabBar.appearance().barTintColor = .black
        UITabBar.appearance().tintColor = .white
    }
} 