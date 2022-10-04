//
//  MainFlow.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/28.
//

import UIKit
import RxFlow
import RxCocoa
import RxSwift

class MainFlow: Flow {
    var root: Presentable {
        return rootViewController
    }
    
    private lazy var rootViewController: UITabBarController = {
        let viewController = UITabBarController()
        viewController.tabBar.layer.borderWidth = 0.50
        viewController.tabBar.layer.borderColor = UIColor.lightGray.cgColor
        viewController.tabBar.clipsToBounds = true
        return viewController
    }()
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .appMain:
            return navigateToMain()
        default:
            return .none
        }
    }
    
    private func navigateToMain() -> FlowContributors {
        let homeFlow = HomeFlow()
        let searchFlow = SearchFlow()
        Flows.use(homeFlow,
                  searchFlow,
                  when: .created) { [unowned self] ( home : UINavigationController,
                                                     search : UINavigationController) in
            
            let homeItem = UITabBarItem(title: "홈",
                                         image: UIImage(named: "today"),
                                         selectedImage: nil)
            
            let searchItem = UITabBarItem(title: "검색",
                                          image: UIImage(named: "search"),
                                          selectedImage: nil)
            
            home.tabBarItem = homeItem
            search.tabBarItem = searchItem

            rootViewController.setViewControllers([home, search],
                                                  animated: false)
            
        }
        
        return .multiple(flowContributors: [.contribute(withNextPresentable: homeFlow,
                                                        withNextStepper:
                                                            OneStepper(withSingleStep:
                                                                        AppStep.appHome)),
                                            .contribute(withNextPresentable: searchFlow,
                                                        withNextStepper:
                                                            OneStepper(withSingleStep:
                                                                        AppStep.appSearch))])
    }
}

class MainStepper: Stepper {
    let steps = PublishRelay<Step>()
    private let disposeBag = DisposeBag()
    var initialStep: Step {
        return AppStep.appMain
    }
}
