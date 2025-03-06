//
//  CoreDataManager.swift
//  NBCampStart
//
//  Created by 서동환 on 3/6/25.
//

import UIKit
import CoreData
import OSLog

final class CoreDataManager {
    private static let log = OSLog(subsystem: "com.snmac.NBCampStart", category: "CoreDataManager")
    
    
    // MARK: - Core Data
    private static let context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            os_log("AppDelegate가 초기화되지 않았습니다.", log: log, type: .error)
            
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    static func saveData(cardData: CardData) {
        guard let context = context else { return }
        guard let entity = NSEntityDescription.entity(
            forEntityName: "CardModel", in: context
        ) else { return }
        
        let studyImagePath: String?
        if let image = cardData.studyImage {
            let fileName = "\(ProcessInfo.processInfo.globallyUniqueString).jpeg"
            let filePath = saveImageToDocuments(image: image, fileName: fileName)
            studyImagePath = filePath
        } else {
            studyImagePath = nil
        }
        
        let object = CardModel(entity: entity, insertInto: context)
        object.uuid = cardData.uuid
        object.studyImagePath = studyImagePath
        object.resolution = cardData.resolution
        object.objective = cardData.objective
        object.date = cardData.date
        
        do {
            try context.save()
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: log, type: .error, msg)
            if let imagePath = studyImagePath {
                deleteImageAtDocuments(filePath: imagePath)
            }
        }
    }
    
    static func fetchData() -> [CardModel] {
        guard let context = context else { return [] }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CardModel")
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            guard let cardList = try context.fetch(fetchRequest) as? [CardModel] else {
                return []
            }
            return cardList
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: log, type: .error, msg)
            return []
        }
    }
    
    static func updateData(cardData: CardData, isImageDirty: Bool) {
        guard let context = context else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "CardModel")
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CardData")
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", cardData.uuid.uuidString)
//        fetchRequest.predicate = NSPredicate(format: "uuid = %@", uuid as CVarArg)
        
        do {
            guard let result = try? context.fetch(fetchRequest),
                  let object = result.first as? NSManagedObject else { return }
            
            if isImageDirty {
                let oldImagePath = object.value(forKey: "studyImagePath") as? String
                if let imagePath = oldImagePath {
                    if deleteImageAtDocuments(filePath: imagePath) {
                        let newImagePath: String?
                        if let image = cardData.studyImage {
                            let fileName = "\(ProcessInfo.processInfo.globallyUniqueString).jpeg"
                            let filePath = saveImageToDocuments(image: image, fileName: fileName)
                            newImagePath = filePath
                        } else {
                            newImagePath = nil
                        }
                        
                        object.setValue(newImagePath, forKey: "studyImagePath")
                    }
                }
            }
            
            object.setValue(cardData.resolution, forKey: "resolution")
            object.setValue(cardData.objective, forKey: "objective")
            
            try context.save()
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: log, type: .error, msg)
        }
    }
    
    static func deleteData(uuid: UUID) {
        guard let context = context else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "CardModel")
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", uuid.uuidString)
        
        do {
            guard let result = try? context.fetch(fetchRequest),
                  let object = result.first as? NSManagedObject else { return }
            
            let studyImagePath = object.value(forKey: "studyImagePath") as? String
            if let imagePath = studyImagePath {
                deleteImageAtDocuments(filePath: imagePath)
            }
            context.delete(object)
            try context.save()
            
        } catch {
            let msg = error.localizedDescription
            os_log("error: %@", log: log, type: .error, msg)
        }
    }
    
    
    // MARK: - Image Data
    // 로컬 디렉토리에 이미지 저장
    static func saveImageToDocuments(image: UIImage, fileName: String) -> String? {
        if let data = image.jpegData(compressionQuality: 0.5) {
            let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try data.write(to: filePath)
                return filePath.path
            } catch {
                let msg = "\(error)"
                os_log("Failed to save image to documents: %@", log: log, type: .error, msg)
            }
        }
        return nil
    }
    
    // 로컬 디렉토리에서 이미지 로드
    static func fetchImageFromDocuments(filePath: String) -> UIImage? {
        if FileManager.default.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)
        }
        return nil
    }
    
    // 로컬 디렉토리에서 이미지 삭제
    @discardableResult
    static func deleteImageAtDocuments(filePath: String) -> Bool {
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
                return true
            } catch {
                let msg = "\(error)"
                os_log("Failed to delete image to documents: %@", log: log, type: .error, msg)
            }
        }
        
        return false
    }
    
    // Documents 디렉토리 경로 가져오기
    static func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

