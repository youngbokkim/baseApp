//
//  HomeCollectionViewCell.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/01.
//

import UIKit
import RxSwift
import RxCocoa

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var webFormatImgView: UIImageView!
    @IBOutlet weak var userProfileImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likeCntLabel: UILabel!
    @IBOutlet weak var commentCntLabel: UILabel!
    
    private var disposeBag = DisposeBag()
    private var cellUpdate = PublishRelay<updateType>()
    
    var viewModel: HomeCollectionViewCellViewModel? {
        didSet {
            bindData()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        disposeBag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

fileprivate extension HomeCollectionViewCell {

    func configurationUI() {
        baseView.layer.cornerRadius = 10.0
        baseView.layer.borderWidth = 1.0
        baseView.layer.borderColor = UIColor.gray.cgColor
        baseView.alpha = 0.5
        baseView.clipsToBounds = true

        userProfileImgView.layer.cornerRadius = userProfileImgView.frame.width / 2
        userProfileImgView.clipsToBounds = true
    }
    
    func bindData() {
        configurationUI()
        
        disposeBag = DisposeBag()
        guard let viewModel = viewModel
        else { return }
 
        viewModel.bind(output: cellUpdate)
        cellUpdate.bind { type in
            switch type {
            case .select:
                UIView.animate(withDuration: 0.3,
                               animations: {
                    self.baseView.alpha = 1.0
                })
                break
            case .deSelect:
                UIView.animate(withDuration: 0.3,
                               animations: {
                    self.baseView.alpha = 0.5
                })
                break
            }
        }.disposed(by: disposeBag)
        
        if let url = viewModel.webFormatUrl {
            webFormatImgView.setImageUrl(url: url, key: viewModel.imageKeyPath(url: url))
                .disposed(by: disposeBag)
        }
        
        if let url = viewModel.userImgUrl {
            userProfileImgView.setImageUrl(url: url, key: viewModel.imageKeyPath(url: url))
                .disposed(by: disposeBag)
        }
        
        likeCntLabel.text = "\(viewModel.likes)"
        commentCntLabel.text = "\(viewModel.comments)"
        nameLabel.text = "\(viewModel.user)"
    }
}
