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
    
    private let CELL_WIDTH = 250.0
    private let CELL_HEIGHT = 330.0
    private var currentIndex: CGFloat = 0.0
    private let lineSpacing: CGFloat = 0.0
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    private let viewLoad: PublishRelay<Void> = PublishRelay()
    private let fetchHisData: PublishRelay<Int> = PublishRelay()
    private let cellSelect: PublishRelay<Int> = PublishRelay()
    private let goDetail: PublishRelay<Hit> = PublishRelay()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCommon()
        fetchHisData.accept(Int(1))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configurationUI() {
        initView()
        
        //startNextPageLoop()
    }
    
    func bindInput() -> ViewModelType.Input {
        return ViewModelType.Input(viewLoad: viewLoad.asObservable(),
                                   fetchedHisData: fetchHisData.asObservable(),
                                   cellSelect: cellSelect.asObservable(),
                                   goDetail: goDetail.asObservable())
    }
    
    func bindOutput(input: ViewModelType.Input) {
        let output = viewModel.transform(input: input)
        output.dataSource.asObservable().bind(to: collectionView.rx
            .items(cellIdentifier: "HomeCollectionViewCell",
                   cellType: HomeCollectionViewCell.self)) { index, data, cell in
            cell.viewModel = HomeCollectionViewCellViewModel(idx: index, hitInfo: data, updateCell: self.cellSelect.asObservable())
            if index == 0 && self.currentIndex == 0 {
                self.cellSelect.accept(0)
            }
        }.disposed(by: disposeBag)
        
       _ = output.hitsInfo.bind { hit in
            self.titleLabel.text = "\(hit.type)"
            self.subTitleLabel.text = "\(hit.tags)"
        }
    }
    
    func bindUI() {
        collectionView
            .rx
            .modelSelected(Hit.self)
            .subscribe(onNext: { (model) in
                print("\(model)")
                self.goDetail.accept(model)
            }).disposed(by: disposeBag)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = CELL_WIDTH
        let cellHeight = CELL_HEIGHT
        return CGSize(width: cellWidth, height: cellHeight)
    }
}


extension HomeViewController : UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
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
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
        
        if viewModel.getMaxLength() - 2 == Int(currentIndex) {
            fetchHisData.accept(Int(currentIndex))
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //let indexPath =  IndexPath(item: Int(self.currentIndex), section: 0)
        
        //self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        cellSelect.accept(Int(currentIndex))
    }
}

fileprivate extension HomeViewController {
    func initView() {
        self.title = viewModel.title
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.init(red: 66, green: 74, blue: 123)
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let cellWidth = CELL_WIDTH
        let cellHeight = CELL_HEIGHT
        let insetX = (view.bounds.width - cellWidth) / 2.0
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = lineSpacing
        layout.scrollDirection = .horizontal
        collectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    func startNextPageLoop() {
        let _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            self.moveNextPage()
        }
    }
    
    func moveNextPage() {
        currentIndex += 1
        collectionView.scrollToItem(at: NSIndexPath(item: Int(currentIndex), section: 0) as IndexPath, at: .right, animated: true)
    }
}
