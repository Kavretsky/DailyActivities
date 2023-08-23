//
//  TypeStore.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 15.08.2023.
//

import Foundation
import UIKit
import Combine

class TypeStore {
    private var types = [ActivityType]()
    {
        didSet {
            typeSubject.send(true)
        }
    }
    
    init() {
        addDefaultTypes()
        print("init")
    }
    
    deinit {
        print("deinit")
    }
    
    private var typeSubject = CurrentValueSubject<Bool, Never>(true)
    
    var typesPublisher: AnyPublisher<Bool, Never> {
        typeSubject.eraseToAnyPublisher()
    }
    
    private func addDefaultTypes() {
        addType(id: "4300197B-201F-42CC-AB52-67186E41F668", emoji: "👍", background: UIColor(rgbaColor: RGBAColor(red: 182/255, green: 255/255, blue: 137/255, alpha: 1)), description: "Positive activity")
        addType(id: "C286CACB-51A6-4FD8-87E1-6900C8ECC1A9", emoji: "😡", background: UIColor(rgbaColor: RGBAColor(red: 255/255, green: 194/255, blue: 137/255, alpha: 1)), description: "Negative activity")
        addType(emoji: "😇", background: UIColor(rgbaColor: RGBAColor(red: 115/255, green: 14/255, blue: 137/255, alpha: 1)), description: "Rest activity")
        addType(emoji: "🥰", background: UIColor(rgbaColor: RGBAColor(red: 15/255, green: 140/255, blue: 17/255, alpha: 1)), description: "Love activity")
    }
    
    var activeTypes: [ActivityType] {
        types.filter { $0.isActive }
    }
    
    var typesToDelete: [ActivityType] {
        types.filter { !$0.isActive }
    }
    
    func type(withID id: String) -> ActivityType {
        types.first(where: { $0.id == id }) ?? types.first(where: { $0.isActive })!
    }
    
    func restore(_ type: ActivityType) {
        if let index = types.firstIndex(of: type) {
            types[index].isActive = true
        }
    }
    
    func addType(id: String = UUID().uuidString,emoji: String, background: UIColor, description: String) {
        guard !emoji.isEmpty,
              emoji.first!.isEmoji
        else { return }
        
        let background = RGBAColor(color: background)
        let shortLabel = String("\(emoji.first!)")
        types.append(ActivityType(id: id, emoji: shortLabel, backgroundRGBA: background, description: description))
    }
    
    @discardableResult
    func addType(with data: ActivityType.Data) -> ActivityType? {
        guard !data.emoji.isEmpty, data.emoji.first!.isEmoji else { return nil }
        
        types.append(ActivityType(data: data))
        return activeTypes.last
    }
    
    func removeType(_ type: ActivityType) {
        guard activeTypes.count > 2 else { return }
        if let index = types.firstIndex(where: {$0.id == type.id}) {
            types[index].isActive = false
        }
    }
    
    func updateType(_ type: ActivityType, with data: ActivityType.Data) {
        guard !data.emoji.isEmpty else { return }
        types[type].update(from: data)
    }
}
