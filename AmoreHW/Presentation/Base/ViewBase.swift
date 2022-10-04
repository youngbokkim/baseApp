//
//  ViewBase.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/09/28.
//

import RxSwift
import Reusable
import UIKit

protocol ViewBase {
    associatedtype ViewModelType: ViewModelBase
    var viewModel: ViewModelType! { get set }
    var disposeBag: DisposeBag { get }
    func setupCommon()
    func configurationUI()
    func bindViewModel()
    func bindInput() -> ViewModelType.Input
    func bindOutput(input: ViewModelType.Input)
    func bindUI()
}

extension ViewBase {
    func setupCommon() {
        configurationUI()
        bindViewModel()
    }
    func bindViewModel() {
        bindOutput(input: bindInput())
        bindUI()
    }
}

extension ViewBase where Self: StoryboardBased & UIViewController {
    static func instantiate<ViewModelType> (withViewModel viewModel: ViewModelType) -> Self
        where ViewModelType == Self.ViewModelType {
        var viewController = Self.instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}
