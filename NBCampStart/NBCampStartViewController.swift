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
    private var cardModelArr: [CardModel] = []
    
    enum Section: Int {
        case main
    }
    typealias Item = CardModel
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var addButton: UIButton!
    
    
    // MARK: - IBActions
    @IBAction func addCardData(_ sender: Any) {
        let addCardModalVC = CardDataModalViewController(
            addDataDelegate: self,
            isEditModal: false
        )
        let modalNC = UINavigationController(rootViewController: addCardModalVC)
        self.present(modalNC, animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "내일배움캠프를 시작하며"
        
        setupUI()
    }
}


// MARK: - UI Methods
private extension NBCampStartViewController {
    func setupUI() {
        pageControl.backgroundStyle = .prominent
        fetchCardModel()
        setCollectionView()
    }
    
    func fetchCardModel() {
        cardModelArr = CoreDataManager.fetchData()
        pageControl.numberOfPages = cardModelArr.count
    }
    
    func setCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCell else {
                return UICollectionViewCell()
            }
            
            let cardModel = item
            var image: UIImage?
            if let imagePath = cardModel.studyImagePath {
                image = CoreDataManager.fetchImageFromDocuments(filePath: imagePath)
            }
            
            let cardData = CardData(
                uuid: cardModel.uuid!,
                studyImage: image,
                resolution: cardModel.resolution,
                objective: cardModel.objective,
                date: cardModel.date!
            )
            cell.backgroundColor = .systemBackground
            cell.configure(cardData)
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cardModelArr, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        collectionView.collectionViewLayout = layout()
        collectionView.alwaysBounceVertical = false
        collectionView.layer.cornerRadius = 10
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
    }
    
    func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(0.8))
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
    
    func reloadData() {
        fetchCardModel()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cardModelArr, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}


// MARK: - UICollectionViewDelegate
extension NBCampStartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section != cardModelArr.count {
            let card = cardModelArr[indexPath.section]
            var image: UIImage?
            if let imagePath = card.studyImagePath {
                image = CoreDataManager.fetchImageFromDocuments(filePath: imagePath)
            }
            let cardData = CardData(
                uuid: card.uuid ?? UUID(),
                studyImage: image,
                resolution: card.resolution,
                objective: card.objective,
                date: card.date ?? .now)
            let cardVC = CardViewController(
                sendDataDelegate: self,
                cardData: cardData
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
    }
}


// MARK: - SendDataDelegate
extension NBCampStartViewController: SendDataDelegate {
    func editData(cardData: CardData, isImageDirty: Bool) {
        CoreDataManager.updateData(cardData: cardData, isImageDirty: isImageDirty)
        reloadData()
    }
    
    func deleteData(uuid: UUID) {
        CoreDataManager.deleteData(uuid: uuid)
        reloadData()
    }
}
