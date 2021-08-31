//
//  DataManager+DietEntity.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/27.
//

import Foundation
import CoreData

extension DataManager {
    func createDiaryEntity(height: Float32, weight: Float32, memo: String, date: Date, context: NSManagedObjectContext, completion:@escaping () -> Void) {
        context.perform {
            let newDiaryEntity = DiaryEntity(context: context)
            
            newDiaryEntity.height = height
            newDiaryEntity.weight = weight
            newDiaryEntity.memo = memo
            newDiaryEntity.date = date
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
                return
            }
            completion()
        }
    }
    
    func fetchDiaryEntity(context: NSManagedObjectContext) -> [DiaryEntity] {
        var entity = [DiaryEntity]()
        context.performAndWait {
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
                entity = try context.fetch(request)
            } catch {
                return
            }
        }
        return entity
    }
    
    func updateDiaryEntity(context: NSManagedObjectContext,  entity: DiaryEntity, height: Float32, weight: Float32, memo: String, date: Date,  completion: @escaping () -> Void) {
        context.perform {
            entity.height = height
            entity.weight = weight
            entity.memo = memo
            entity.date = date
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
                print(error.localizedDescription)
                return
            }
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

