//
//  NBCampStartViewController.swift
//  NBCampStart
//
//  Created by 서동환 on 3/4/25.
//

import UIKit

protocol AlbumDataDelegate: AnyObject {
    func addData(albumData: AlbumData)
    func editData(albumData: AlbumData, indexPathItem: Int)
    func deleteData(indexPathItem: Int)
}

class NBCampStartViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addAlbumData(_ sender: Any) {
        let addAlbumModalVC = AlbumDataModalViewController()
        addAlbumModalVC.delegate = self
        
        if let sheet = addAlbumModalVC.sheetPresentationController {
            sheet.detents = [.large()]
        }
        let modalNC = UINavigationController(rootViewController: addAlbumModalVC)
        self.present(modalNC, animated: true)
    }
    
    let sectionInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
    var albumData: [AlbumData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "내일배움캠프를 시작하며"
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didDismissDetailNotification(_:)),
            name: NSNotification.Name("DismissAlbumDataModalView"),
            object: nil
        )
        
        setupUI()
    }
    
    @objc func didDismissDetailNotification(_ notification: Notification) {
          DispatchQueue.main.async {
              self.collectionView.reloadData()
          }
      }
    
    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 10
        collectionView.backgroundColor = .clear
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = .zero
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NBCampStartViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        let itemsPerRow: CGFloat = 1
        let widthPadding = sectionInsets.left * (itemsPerRow + 1)
        let itemsPerColumn: CGFloat = 1
        let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
        let cellWidth = (width - widthPadding) / itemsPerRow
        let cellHeight = (height - heightPadding) / itemsPerColumn
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
}

// MARK: - UICollectionViewDelegate
extension NBCampStartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item != albumData.count {
            let editAlbumModalVC = AlbumDataModalViewController()
            editAlbumModalVC.delegate = self
            editAlbumModalVC.albumData = albumData[indexPath.item]
            editAlbumModalVC.indexPathItem = indexPath.item
            editAlbumModalVC.isEdit = true
            
            if let sheet = editAlbumModalVC.sheetPresentationController {
                sheet.detents = [.large()]
            }
            let modalNC = UINavigationController(rootViewController: editAlbumModalVC)
            self.present(modalNC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension NBCampStartViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if albumData.count == 0 {
            return 1
        } else {
            return albumData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell else {
            return UICollectionViewCell()
        }
        
        if albumData.count == 0 {
            let addPromptData = AlbumData(resolution: "오늘의 다짐을 생각해보세요",
                                          objective: "오늘의 학습 목표를 세워보세요")
            cell.configure(albumData: addPromptData)
            cell.backgroundColor = .systemBackground.withAlphaComponent(0.9)
        } else {
            cell.configure(albumData: albumData[indexPath.item])
            cell.backgroundColor = .systemBackground
        }
        
        return cell
    }
}

// MARK: - SendDelegate
extension NBCampStartViewController: AlbumDataDelegate {
    func addData(albumData: AlbumData) {
        self.albumData.append(albumData)
        self.collectionView.reloadData()
    }
    
    func editData(albumData: AlbumData, indexPathItem: Int) {
        self.albumData[indexPathItem] = albumData
        self.collectionView.reloadData()
    }
    
    func deleteData(indexPathItem: Int) {
        self.albumData.remove(at: indexPathItem)
        self.collectionView.reloadData()
    }
}
