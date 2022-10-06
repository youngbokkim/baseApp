//
//  HomeViewController.swift
//  AmoreHW
//
//  Created by kim youngbok on 2022/10/01.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController, StoryboardBased, ViewBase {
    typealias ViewModelType = HomeViewModel
    var viewModel: ViewModelType!
    var disposeBag: DisposeBag = DisposeBag()
    
    private let constCellWidth = 250.0
    private let constCellHeight = 330.0
    private var currentIndex: CGFloat = 0.0
    private var timerPause: Bool = false
    private var timer: Timer?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    private let viewLoad: PublishRelay<Void> = PublishRelay()
    private let fetchedHitsData: PublishRelay<Int> = PublishRelay()
    private let cellSelect: PublishRelay<Int> = PublishRelay()
    private let goDetail: PublishRelay<Hit> = PublishRelay()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = view.center
        activityIndicator.color = UIColor.white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        view.addSubview(activityIndicator)
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCommon()
        fetchedHitsData.accept(Int(1))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cellUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    func configurationUI() {
        initView()
        startNextPageLoop()
    }
    
    func bindInput() -> ViewModelType.Input {
        return ViewModelType.Input(viewLoad: viewLoad.asObservable(),
                                   fetchedHitsData: fetchedHitsData.asObservable(),
                                   cellSelect: cellSelect.asObservable(),
                                   goDetail: goDetail.asObservable())
    }
    
    func bindOutput(input: ViewModelType.Input) {
        let output = viewModel.transform(input: input)
        output.dataSource.asObservable().bind(to: collectionView.rx
            .items(cellIdentifier: "HomeCollectionViewCell",
                   cellType: HomeCollectionViewCell.self)) { [weak self] (index, data, cell) in
            guard let self = self else { return }
            
            cell.viewModel = HomeCollectionViewCellViewModel(idx: index, hitInfo: data, updateCell: self.cellSelect.asObservable())
            
            if index == 0 && self.currentIndex == 0 {
                self.cellSelect.accept(0)
            }
            self.activityIndicator.stopAnimating()
        }.disposed(by: disposeBag)
        
        output.errorHandler.asObservable().bind(onNext: { [weak self] error in
            guard let self = self else { return }
            
            self.showErrorMsg(error: error)
            self.timer?.invalidate()
        }).disposed(by: disposeBag)
        
       _ = output.hitsInfo.bind { [weak self] hit in
            guard let self = self else { return }
           
            self.titleLabel.text = "\(hit.type)"
            self.subTitleLabel.text = "\(hit.tags)"
        }
    }
    
    func bindUI() {
        collectionView
            .rx
            .modelSelected(Hit.self)
            .subscribe(onNext: { [weak self] (model) in
                self?.goDetail.accept(model)
            }).disposed(by: disposeBag)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = constCellWidth
        let cellHeight = constCellHeight
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension HomeViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        timer?.invalidate()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        cellUpdate()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidth = layout.itemSize.width
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidth
        var roundedIndex = round(index)
        
        if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            roundedIndex = floor(index)
        } else if scrollView.contentOffset.x < targetContentOffset.pointee.x {
            roundedIndex = ceil(index)
        } else {
            roundedIndex = round(index)
        }
        
        if currentIndex > roundedIndex {
            currentIndex -= 1
            roundedIndex = currentIndex
        } else if currentIndex < roundedIndex {
            currentIndex += 1
            roundedIndex = currentIndex
        }
        
        offset = CGPoint(x: roundedIndex * cellWidth - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cellUpdate()
    }
}

fileprivate extension HomeViewController {
    func initView() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.init(red: 66, green: 74, blue: 123)
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.title = viewModel.title
        
        let cellWidth = constCellWidth
        let cellHeight = constCellHeight
        let insetX = (view.bounds.width - cellWidth) / 2.0
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    func startNextPageLoop() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            self?.moveNextPage()
        }
    }
    
    func moveNextPage() {
        guard viewModel.getMaxLength() > Int(currentIndex)
        else { return }
        
        currentIndex += 1
        collectionView.scrollToItem(at: NSIndexPath(item: Int(currentIndex), section: 0) as IndexPath, at: .right, animated: true)
    }
    
    func cellUpdate(){
        guard viewModel.getMaxLength() > Int(currentIndex)
        else { return }
        
        if viewModel.getMaxLength() == Int(currentIndex + 1) {
            activityIndicator.startAnimating()
            fetchedHitsData.accept(viewModel.getMaxLength() + 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.cellSelect.accept(Int(self!.currentIndex))
            }
        } else {
            cellSelect.accept(Int(currentIndex))
        }
        startNextPageLoop()
    }
    
    func showErrorMsg(error: Error) {
        let vc = UIAlertController.init(title: "에러", message: error.localizedDescription, preferredStyle: .alert)
        let confirm = UIAlertAction.init(title: "확인", style: .cancel)
        vc.addAction(confirm)
        self.present(vc, animated: true)
    }
}
