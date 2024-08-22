//
//  ActivityCoreDataRepository.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 30.07.2024.
//

import CoreData
import Combine

enum ActivityCoreDataRepositoryError: Error {
    case invalidActivityData
    case activityNotFound
}

protocol ActivityReadableRepository {
    func fetchActivities(for date: Date) -> [Activity]
}

protocol ActivityWritableRepository {
    func addActivity(_ activity: Activity) async throws
    func updateActivity(_ activity: Activity) async throws
    func deleteActivity(_ activity: Activity) async throws
    var activityDidChangedPublisher: CurrentValueSubject<Bool, Never> { get }
}

final class ActivityCoreDataRepository: ActivityReadableRepository, ActivityWritableRepository {
    @Published private var cachedActivitiesByDate: [Date: [Activity]] = [:] {
        didSet {
            activityDidChangedPublisher.send(false)
        }
    }
    private let mutex = NSLock()
    private(set) var activityDidChangedPublisher: CurrentValueSubject<Bool, Never> = .init(true)
    let context: NSManagedObjectContext
    var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        Task {
            do {
                let activities = try fetchActivitiesFromCoreData()
                let activitiesByDate = Dictionary(grouping: activities, by: { Calendar.current.startOfDay(for: $0.startDateTime) })
                mutex.withLock {
                    self.cachedActivitiesByDate = activitiesByDate
                }
                self.activityDidChangedPublisher.send(true)
                
            } catch {
                print("failed to fetch activities from CoreData: \(error)" )
            }
        }
    }
    
    private func fetchActivitiesFromCoreData() throws -> [Activity] {
        try context.performAndWait {
            let request = ActivityEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "startDateTime", ascending: true)]
            let result = try context.fetch(request)
            if let last = result.last, last.finishDateTime == nil, 
                !(last.startDateTime?.isSameDay(with: .now) ?? false),
                let startDateTime = last.startDateTime {
                last.finishDateTime = .endOfDay(for: startDateTime)
            }
            return result.map {Activity(from: $0)}
        }
    }
    
    func addActivity(_ activity: Activity) async throws {
        try await context.perform { [weak self] in
            guard let self else { return }
            try self.finishCurrentActivity(before: activity)
            let entity = ActivityEntity(context: self.context)
            entity.id = activity.id
            entity.desc = activity.description
            entity.startDateTime = activity.startDateTime
            entity.typeID = activity.typeID
            try context.save()
        }
        mutex.withLock {
            cachedActivitiesByDate[Calendar.current.startOfDay(for: activity.startDateTime), default: []].append(activity)
        }
    }
    
    func fetchActivities(for date: Date) -> [Activity] {
        let startDay = Calendar.current.startOfDay(for: date)
        return cachedActivitiesByDate[startDay, default: []]
        
    }
    
    func updateActivity(_ activity: Activity) async throws {
        guard let index = cachedActivitiesByDate[Calendar.current.startOfDay(for: activity.startDateTime)]?.firstIndex(where: {
            $0.id == activity.id
        }) else { throw ActivityCoreDataRepositoryError.activityNotFound }
        guard activity.startDateTime <= activity.finishDateTime ?? .now else { throw ActivityCoreDataRepositoryError.invalidActivityData }
        
        try await context.perform { [weak self] in
            guard let self else { return }
            guard let entity = try getActivityEntity(by: activity.id) else { throw ActivityCoreDataRepositoryError.activityNotFound }
            entity.desc = activity.description
            entity.finishDateTime = activity.finishDateTime
            entity.startDateTime = activity.startDateTime
            entity.typeID = activity.typeID
            try context.save()
        }
        mutex.withLock {
            cachedActivitiesByDate[Calendar.current.startOfDay(for: activity.startDateTime)]?[index] = activity
        }

    }
    
    func deleteActivity(_ activity: Activity) async throws {
        guard let index = cachedActivitiesByDate[Calendar.current.startOfDay(for: activity.startDateTime)]?.firstIndex(of: activity) else { return }
        try await context.perform { [weak self] in
            guard let self else { return }
            guard let entity = try getActivityEntity(by: activity.id) else { return }
            context.delete(entity)
            try context.save()
        }
        mutex.withLock {
            cachedActivitiesByDate[Calendar.current.startOfDay(for: activity.startDateTime)]?.remove(at: index)
        }
    }
    
    private func getActivityEntity(by id: String) throws -> ActivityEntity? {
        let request = ActivityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        return try context.fetch(request).first
    }
    
    private func finishCurrentActivity(before newActivity: Activity) throws {
        try context.performAndWait {
            let request = ActivityEntity.fetchRequest()
            let endOfDay = Date.endOfDay(for: newActivity.startDateTime)
            let startOfDay = Date.startOfDay(for: newActivity.startDateTime)
            request.predicate = NSPredicate(format: "finishDateTime == nil AND startDateTime <= %@ AND startDateTime >= %@", endOfDay as NSDate, startOfDay as NSDate)

            request.sortDescriptors = [NSSortDescriptor(keyPath: \ActivityEntity.startDateTime, ascending: true)]
            guard let currentActivity = try context.fetch(request).first else { return }
            if let startDate = currentActivity.startDateTime {
                currentActivity.finishDateTime = startDate.isSameDay(with: Date()) ? newActivity.startDateTime : .endOfDay(for: startDate)
            }
            let activity = Activity(from: currentActivity)
            if let index = cachedActivitiesByDate[Calendar.current.startOfDay(for: activity.startDateTime)]?.firstIndex(where: {$0.finishDateTime == nil}) {
                mutex.withLock {
                    cachedActivitiesByDate[Calendar.current.startOfDay(for: activity.startDateTime)]?[index] = activity
                }
            }
        }
        
    }
}
