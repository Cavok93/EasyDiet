//
//  DataManager+DietEntity.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/27.
//

import Foundation
import CoreData





extension DataManager {
    
    
    func createDiaryEntity(height: Float32, weight: Float32, memo: String, date: Date, dateForSort: Date = Date(), context: NSManagedObjectContext, completion:@escaping () -> Void) {
        context.perform {
            let newDiaryEntity = DiaryEntity(context: context)

            newDiaryEntity.height = height
            newDiaryEntity.weight = weight
            newDiaryEntity.memo = memo
            newDiaryEntity.date = date
            newDiaryEntity.dateForSort = dateForSort
            do {
                try context.save()
            } catch {
                fatalError()
            }
            completion()
        }
    }
    
    
    
    func fetchDiaryEntity(context: NSManagedObjectContext) -> [DiaryEntity] {
        var entity = [DiaryEntity]()
        context.performAndWait {
            let request: NSFetchRequest<DiaryEntity> = DiaryEntity.fetchRequest()
            let sortByDate = NSSortDescriptor(key: #keyPath(DiaryEntity.dateForSort), ascending: false)
            request.sortDescriptors = [sortByDate]
            request.propertiesToFetch = [
                #keyPath(DiaryEntity.date),
                #keyPath(DiaryEntity.height),
                #keyPath(DiaryEntity.weight),
                #keyPath(DiaryEntity.memo)
            ]
            request.fetchBatchSize = 30
            do {
                entity = try context.fetch(request)
            } catch {
                fatalError()
            }
        }
        return entity
    }
    
    
    func updateDiaryEntity(context: NSManagedObjectContext,  entity: DiaryEntity, height: Float32, weight: Float32, memo: String, date: Date, dateForSort: Date = Date(),  completion: @escaping () -> Void) {
        context.perform {
            entity.height = height
            entity.weight = weight
            entity.memo = memo
            entity.date = date
            entity.dateForSort = dateForSort
            DataManager.shared.saveContext()
            completion()
        }
    }
    
    func deleteDietEntity(entity: DiaryEntity, context: NSManagedObjectContext) {
        context.perform {
            context.delete(entity)
            do {
                try context.save()
                
            } catch {
                fatalError()
            }
        }
        
    }
}

