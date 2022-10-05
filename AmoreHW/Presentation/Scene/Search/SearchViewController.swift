//
//  SearchViewController.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/01.
//

import UIKit
import Reusable
import RxSwift

class SearchViewController: UIViewController, StoryboardBased, ViewBase {
    typealias ViewModelType = SearchViewModel
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
