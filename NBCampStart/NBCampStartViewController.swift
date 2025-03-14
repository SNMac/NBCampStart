//
//  NBCampStartViewController.swift
//  NBCampStart
//
//  Created by 서동환 on 3/4/25.
//

import UIKit
import CoreData

protocol AddDataDelegate: AnyObject {
    func addData(cardData: CardData)
}

protocol SendDataDelegate: AnyObject {
    func editData(cardData: CardData, isImageDirty: Bool)
    func deleteData(uuid: UUID)
}

class NBCampStartViewController: UIViewController {
    private var cardDataList = [CardData]()
    private var cardDataDic = [UUID: CardData]()
    
    private enum Section: Int {
        case main
    }
    private var dataSource: UICollectionViewDiffableDataSource<Section, UUID>!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var promptView: UIView!
    @IBOutlet weak var promptImageView: UIImageView!
    @IBOutlet weak var promptResolutionLabel: UILabel!
    @IBOutlet weak var promptObjectiveLabel: UILabel!
    @IBOutlet weak var promptDateLabel: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func changePage(_ sender: UIPageControl) {
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    @IBAction func addCardData(_ sender: Any) {
        let addCardModalVC = CardDataModalViewController(
            addDataDelegate: self,
            isEditModal: false
        )
        let modalNC = UINavigationController(rootViewController: addCardModalVC)
        self.present(modalNC, animated: true)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "내일배움캠프를 시작하며"
        
        setupUI()
    }
}

// MARK: - UI Methods

private extension NBCampStartViewController {
    func setupUI() {
        promptView.backgroundColor = .systemBackground.withAlphaComponent(0.85)
        promptView.layer.cornerRadius = 10
        promptImageView.layer.cornerRadius = 10
        let dateFormatter = DateFormatter.getDateFormatter()
        let convertDate = dateFormatter.string(from: .now)
        promptDateLabel.text = convertDate
        pageControl.backgroundStyle = .prominent
        fetchCardData()
        setCollectionView()
    }
    
    func fetchCardData() {
        cardDataList = CoreDataManager.fetchData()
        let tupleArray = cardDataList.map { ($0.uuid, $0) }
        cardDataDic = Dictionary(uniqueKeysWithValues: tupleArray)
        pageControl.numberOfPages = cardDataDic.count
        if pageControl.numberOfPages == 0 {
            pageControl.isHidden = true
            promptView.isHidden = false
        } else {
            pageControl.isHidden = false
            promptView.isHidden = true
        }
    }
    
    func setCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView, cellProvider: { collectionView, indexPath, uuid in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCell else {
                return UICollectionViewCell()
            }
            
            let cardData = self.cardDataDic[uuid]
            cell.backgroundColor = .secondarySystemBackground
            cell.configure(cardData)
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cardDataList.map { $0.uuid }, toSection: .main)
        dataSource.applySnapshotUsingReloadData(snapshot)
        
        collectionView.collectionViewLayout = layout()
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
    }
    
    func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 20
        
        section.visibleItemsInvalidationHandler = { item, offset, env in
            let index = Int((offset.x / env.container.contentSize.width).rounded(.up))
            self.pageControl.currentPage = index
        }
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    // 특정 uuid에 해당하는 셀만 업데이트(추가, 삭제 X)
    func updateData(uuid: UUID) {
        fetchCardData()
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([uuid])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // 모든 셀 업데이트(추가, 삭제 O)
    func reloadData() {
        fetchCardData()
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cardDataList.map { $0.uuid }, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate

extension NBCampStartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cardDataId = dataSource.itemIdentifier(for: indexPath) {
            let cardData = cardDataDic[cardDataId]
            let cardVC = CardViewController(
                sendDataDelegate: self,
                cardData: cardData!
            )
            self.navigationController?.pushViewController(cardVC, animated: true)
        }
    }
}

// MARK: - AddDataDelegate

extension NBCampStartViewController: AddDataDelegate {
    func addData(cardData: CardData) {
        CoreDataManager.saveData(cardData: cardData)
        reloadData()
        pageControl.currentPage = 0
        let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - SendDataDelegate

extension NBCampStartViewController: SendDataDelegate {
    func editData(cardData: CardData, isImageDirty: Bool) {
        CoreDataManager.updateData(cardData: cardData, isImageDirty: isImageDirty)
        updateData(uuid: cardData.uuid)
    }
    
    func deleteData(uuid: UUID) {
        CoreDataManager.deleteData(uuid: uuid)
        reloadData()
    }
}
