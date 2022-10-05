//
//  HomeDetailViewController.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/04.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa

class HomeDetailViewController: UIViewController, StoryboardBased, ViewBase  {
    typealias ViewModelType = HomeDetailViewModel
    var viewModel: ViewModelType!
    var disposeBag: DisposeBag = DisposeBag()
    
    @IBOutlet weak var webImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewLoad = PublishRelay<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCommon()
        viewLoad.accept(Void())
    }
    
    func configurationUI() {
        self.title = viewModel.title
        webImageView.layer.cornerRadius = 10
        webImageView.layer.borderColor = UIColor.lightGray.cgColor
        webImageView.layer.borderWidth = 1
        webImageView.clipsToBounds = true
    }
    
    func bindInput() -> ViewModelType.Input {
        return ViewModelType.Input(viewLoad: viewLoad.asObservable())
    }
    
    func bindOutput(input: ViewModelType.Input) {
        let output = viewModel.transform(input: input)
        output.hitInfo.bind { hit in
            self.updateUI(info: hit)
        }.disposed(by: disposeBag)
    }
    
    func bindUI() {
        
    }
}

fileprivate extension HomeDetailViewController {
    func updateUI(info: Hit) {
        if let url = self.viewModel.webFormatUrl {
            self.webImageView.setImageUrl(url: url, key: self.viewModel.imageKeyPath(url: url)).disposed(by: self.disposeBag)
        }
        self.titleLabel.text = "\(info.tags)"
    }
}
