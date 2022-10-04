//
//  HomeFlow.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/28.
//

import UIKit
import RxFlow

class HomeFlow: Flow {
    var root: Presentable {
        return rootViewController
    }
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        return viewController
    }()
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .appHome:
            return navigateToHome()
        case .appHomeDetail(let info):
            return navigateToHomeDetail(info: info)
        default:
            return .none
        }
    }
    
    private func navigateToHome() -> FlowContributors {
        let ntRepo = NetworkRepository(networkSvc: NetworkService(), baseURL: BASE_URL)
        let useCase = HitsUseCase(networkRepository: ntRepo)
        let viewModel = HomeViewModel(title: "신상", useCase: useCase)
        let viewController = HomeViewController.instantiate(withViewModel: viewModel)
        rootViewController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController,
                                                 withNextStepper: viewModel))
    }
    
    private func navigateToHomeDetail(info: Hit) -> FlowContributors {
        let viewModel = HomeDetailViewModel(title: "상세화면", info: info)
        let viewController = HomeDetailViewController.instantiate(withViewModel: viewModel)
        rootViewController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController,
                                                 withNextStepper: viewModel))
    }
}
