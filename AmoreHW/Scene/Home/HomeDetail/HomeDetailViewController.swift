//
//  HomeDetailViewController.swift
//  AmoreHW
//
//  Created by N4158 on 2022/10/04.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa

class HomeDetailViewController: UIViewController, StoryboardBased, ViewBase  {
    typealias ViewModelType = HomeDetailViewModel
    var viewModel: ViewModelType!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCommon()
    }
    
    func configurationUI() {
        self.title = viewModel.title
    }
    
    func bindInput() -> ViewModelType.Input {
        return ViewModelType.Input()
    }
    
    func bindOutput(input: ViewModelType.Input) {
        let _ = viewModel.transform(input: input)
    }
    
    func bindUI() {
        
    }
}
