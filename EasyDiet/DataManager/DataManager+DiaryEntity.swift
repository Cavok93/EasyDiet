//
//  DataManager+DietEntity.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/27.
//

import Foundation
import CoreData

extension DataManager {
    func createDiaryEntity(height: Float32, weight: Float32, memo: String, date: Date, orderBasedDate: Date = Date(), completion:@escaping () -> Void) {
        mainContext.perform {
            let newDiaryEntity = DiaryEntity(context: self.mainContext)
            newDiaryEntity.height = height
            newDiaryEntity.weight = weight
            newDiaryEntity.memo = memo
            newDiaryEntity.date = date
            newDiaryEntity.orderBasedDate = orderBasedDate
            do {
                try self.mainContext.save()
            } catch {
                print(error.localizedDescription)
                return
            }
            completion()
        }
    }
    
    func fetchDiaryEntity() -> [DiaryEntity] {
        var entity = [DiaryEntity]()
        mainContext.performAndWait {
            let request: NSFetchRequest<DiaryEntity> = DiaryEntity.fetchRequest()
            let sortByDate = NSSortDescriptor(key: #keyPath(DiaryEntity.date), ascending: true)
            request.sortDescriptors = [sortByDate]
            request.propertiesToFetch = [
                #keyPath(DiaryEntity.height),
                #keyPath(DiaryEntity.weight),
                #keyPath(DiaryEntity.memo)
            ]
            request.fetchBatchSize = 30
            do {
                entity = try mainContext.fetch(request)
            } catch {
                return
            }
        }
        return entity
    }
    
    func fetchDiaryEntityByOrderBasedDate() -> [DiaryEntity] {
        var entity = [DiaryEntity]()
        mainContext.performAndWait {
            let request: NSFetchRequest<DiaryEntity> = DiaryEntity.fetchRequest()
            let sortByDate = NSSortDescriptor(key: #keyPath(DiaryEntity.orderBasedDate), ascending: false)
            request.sortDescriptors = [sortByDate]
            request.propertiesToFetch = [
                #keyPath(DiaryEntity.height),
                #keyPath(DiaryEntity.weight),
                #keyPath(DiaryEntity.memo)
            ]
            request.fetchBatchSize = 30
            do {
                entity = try mainContext.fetch(request)
            } catch {
                return
            }
        }
        return entity
    }
    
    func updateDiaryEntity(entity: DiaryEntity, height: Float32, weight: Float32, memo: String, date: Date, orderBasedDate: Date = Date(),  completion: @escaping () -> Void) {
        mainContext.perform {
            entity.height = height
            entity.weight = weight
            entity.memo = memo
            entity.date = date
            entity.orderBasedDate = orderBasedDate
            DataManager.shared.saveContext()
            completion()
        }
    }
    
    
    func deleteDietEntity(entity: DiaryEntity?,
                           completion: @escaping() -> Void) {
        mainContext.perform {
            if let entity = entity {
                self.mainContext.delete(entity)
            }
            self.saveContext()
            completion()
        }
    }
    
    func batchDelete() {
        let request =  NSFetchRequest<NSFetchRequestResult>(entityName: "Diary")
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try mainContext.execute(delete)
        } catch{
            print(error.localizedDescription)
        }
    }
}

