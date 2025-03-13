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
        promptView.backgroundColor = .systemBackground.withAlphaComponent(0.85)
        promptView.layer.cornerRadius = 10
        promptImageView.layer.cornerRadius = 10
        let dateFormatter = DateFormatter.getDateFormatter()
        let convertDate = dateFormatter.string(from: .now)
        promptDateLabel.text = convertDate
        pageControl.backgroundStyle = .prominent
        fetchCardModel()
        setCollectionView()
    }
    
    func fetchCardModel() {
        cardModelArr = CoreDataManager.fetchData()
        pageControl.numberOfPages = cardModelArr.count
        if pageControl.numberOfPages == 0 {
            pageControl.isHidden = true
            promptView.isHidden = false
        } else {
            pageControl.isHidden = false
            promptView.isHidden = true
        }
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
            cell.backgroundColor = .secondarySystemBackground
            cell.configure(cardData)
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cardModelArr, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
        
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
    
    func reloadData() {
        fetchCardModel()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cardModelArr, toSection: .main)
        snapshot.reconfigureItems(cardModelArr)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}


// MARK: - UICollectionViewDelegate
extension NBCampStartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item != cardModelArr.count {
            let card = cardModelArr[indexPath.item]
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
        pageControl.currentPage = 0
        let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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
