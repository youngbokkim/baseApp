//
//  AppDelegate.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/26.
//

import UIKit
import RxFlow
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let disposedBag = DisposeBag()
    var coordinator = FlowCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow()
        
        if let window = window {
            let flow = MainFlow()
            coordinator.coordinate(flow: flow, with: MainStepper())
            Flows.use(flow, when: .created) { root in
                window.rootViewController = root
                window.makeKeyAndVisible()
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}

