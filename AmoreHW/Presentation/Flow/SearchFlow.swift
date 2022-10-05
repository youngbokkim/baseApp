//
//  SearchFlow.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/28.
//

import UIKit
import RxFlow

class SearchFlow: Flow {
    var root: Presentable {
        return rootViewController
    }
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.navigationBar.prefersLargeTitles = false
        return viewController
    }()
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .appSearch:
            return navigateToSearch()
        default:
            return .none
        }
    }
    
    private func navigateToSearch() -> FlowContributors {
        let viewModel = SearchViewModel(title: "검색")
        let viewController = SearchViewController.instantiate(withViewModel: viewModel)
        rootViewController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController,
                                                 withNextStepper: viewModel))
    }
}
