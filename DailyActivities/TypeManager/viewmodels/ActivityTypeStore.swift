//
//  ActivityTypeStore.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 15.08.2023.
//

import Foundation
import Combine

class TypeManagerVM {
    @Published private(set) var types: [ActivityType] = []
    private let typeRepository: ActivityTypeReadableRepository & ActivityTypeWritableRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(activityTypeRepository: ActivityTypeReadableRepository & ActivityTypeWritableRepository) {
        self.typeRepository = activityTypeRepository
        types = typeRepository.types.filter { $0.isActive }
        typeRepository.typesPublisher
            .receive(on: DispatchQueue.global())
            .sink { [weak self] newTypes in
                self?.types = newTypes.filter { $0.isActive }
            }
            .store(in: &cancellables)
    }
    
    func addType(with data: ActivityType.Data) async -> ActivityType? {
        do {
            let newType = try await typeRepository.addType(with: data)
            return newType
        } catch ActivityTypeCoreDataRepositoryError.invalidTypeData {
            print("failed to add type: invalid type data")
        } catch {
            print("failed to add type: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func removeType(_ type: ActivityType) async {
        do {
            print("try to delete type")
            try await typeRepository.deleteType(type)
        } catch ActivityTypeCoreDataRepositoryError.canNotDeleteLastTwoTypes {
            print("can not delete type when 2 or less types")
        } catch {
            print("failed to remove type: \(error.localizedDescription)")
        }
    }
    
    func updateType(_ type: ActivityType, with data: ActivityType.Data) async {
        guard !data.emoji.isEmpty, types.firstIndex(where: { $0.id == type.id }) != nil else { return }
        do {
            try await typeRepository.updateType(type, with: data)
        } catch ActivityTypeCoreDataRepositoryError.invalidTypeData {
            print("failed to add type: invalid type data")
        } catch {
            print(data.backgroundRGBA.red)
            print("failed to update type: \(error.localizedDescription)")
        }
    }
    
    deinit {
        print("\(self) deinited")
    }
    
}
