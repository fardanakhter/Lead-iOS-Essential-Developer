//
//  ClientCode.swift
//  Singletons&GlobalInstances
//
//  Created by Fardan Akhter on 17/03/2023.
//

import Foundation
import UIKit

// ***************************************************************************** //

// 1st Stage: going easy (first dependency diagram)

// Comments:
// 1. All feature modules have common shared dependencies, addition of new feauture will require to change shared module and re-compile all other module frameworks (as all frameworks imports shared module).
// 2. A module has access to all the unneeded methods of shared module.
// 3. Violation of SRP and DIP !

// ***************************************************************************** //

// APIClient Module

//class APIClient {
//    static let shared = APIClient()
//    private init() {}
//
//    func login(completion: @escaping () -> Void) {}
//    func loadFeed(completion: @escaping () -> Void) {}
//}

// Login Module

//class LoginViewController: UIViewController {
//    var api: APIClient = APIClient.shared
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        api.login() {
//            // navigate to next screen
//        }
//    }
//}

// Feed Module

//class FeedViewController: UIViewController {
//    var api: APIClient = APIClient.shared
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        api.loadFeed() {
//            // update UI
//        }
//    }
//}

// Testing Singleton Instances

//class MockAPIClient: APIClient {
//    init() {}
//}

// 1. Inject instance of APIClient subclass as Param
//let vc = LoginViewController()
//vc.api = MockAPIClient()

// 2. Make singleton mutable, change instance of singleton to mock instance before testing and revert after testing
// APIClient.shared = MockAPIClient()


// ***************************************************************************** //

// 2nd Stage: added flexibility (second dependency diagram)
// Comments: seperation of concerns for shared module using extentions

// ***************************************************************************** //

// APIClient Module

//class APIClient {
//    static let shared = APIClient()
//    private init() {}
//
//    func execute(request: URLRequest){}
//}

// Login Module

//extension APIClient {
//    func login(completion: @escaping () -> Void) {}
//}
//
//class LoginViewController: UIViewController {
//    var api: APIClient = APIClient.shared
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        api.login() {
//            // navigate to next screen
//        }
//    }
//}

// Feed Module

//extension APIClient {
//    func loadFeed(completion: @escaping () -> Void) {}
//}
//
//class FeedViewController: UIViewController {
//    var api: APIClient = APIClient.shared
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        api.loadFeed() {
//            // update UI
//        }
//    }
//}

// ***************************************************************************** //

// 3rd Stage: Inverted Dependencies (third & fourth dependency diagram)
// Comments: The high-level module DONOT depend on Low-level module, it should be vice versa.

// ***************************************************************************** //

// APIClient Module

class APIClient {
    static let shared = APIClient()
    private init() {}

    func execute(request: URLRequest){}
    func login(completion: @escaping () -> Void) {}
    func loadFeed(completion: @escaping () -> Void) {}
}

// Login Module

class LoginViewController: UIViewController {
    var login: ((@escaping () -> Void) -> Void)? = nil // This can be either protocol or a closure

    override func viewDidLoad() {
        super.viewDidLoad()
        login?() {
            // update UI
        }
    }
}

// Feed Module

struct Feed {}

class FeedViewController: UIViewController {
    var loadFeed: ((@escaping () -> Void) -> Void)? = nil // This can be either protocol or a closure

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFeed?() {
            // update UI
        }
    }
}

// ***************************************************************************** //

// 4rd Stage: Inverted Dependencies (fifth dependency diagram)
// Comments:
// 1.Responsibilities divided in modules, much more flexibilty and freedom in Testing.
// 2.Main (composition layer) to contain adaptors that composes and initializes instances of all modules.
// 3.addition of new feature module requires change in main and shared module but DOESNT need to re-compile other module frameworks (as dependency is inverted)

// ***************************************************************************** //

// Main module (composition layer)

struct LoginClientAdaptor {
    
    let apiClient: APIClient
    let loginController: LoginViewController
    
    init(apiClient: APIClient, loginController: LoginViewController) {
        self.apiClient = apiClient
        self.loginController = loginController
        
        loginController.login = apiClient.login
    }
    
}

struct FeedClientAdaptor {

    let apiClient: APIClient
    let feedController: FeedViewController
    
    init(apiClient: APIClient, feedController: FeedViewController) {
        self.apiClient = apiClient
        self.feedController = feedController
        
        feedController.loadFeed = apiClient.loadFeed
    }
    
}
