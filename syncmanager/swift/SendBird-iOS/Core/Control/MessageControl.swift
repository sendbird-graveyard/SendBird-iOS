//
//  MessageControl.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/13.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import SendBirdSyncManager

class MessageControl {
     
    var models: [MessageModel] = []
    var pendingFileMessageParams: [String:SBDFileMessageParams] = [:]
    
    func cleanMessage() {
        self.models = []
    }
}

// MARK: - Find
extension MessageControl {
    
    func findIndex(by model: MessageModel) -> Int? {
        return self.findIndex(by: model.message)
    }
    
    func findIndex(by message: SBDBaseMessage) -> Int? {
        return self.models.firstIndex { $0.message == message || $0.requestID == message.requestID }
    }
    
    func findIndexPath(by model: MessageModel) -> IndexPath? {
        return self.findIndexPath(by: model.message)
    }
    
    func findIndexPath(by message: SBDBaseMessage) -> IndexPath? {
        guard let index = findIndex(by: message) else { return nil }
        return IndexPath(row: index, section: 0)
    }
    
    func findModel(by model: MessageModel) -> MessageModel? {
        return self.findModel(by: model.message)
    }
    
    func findModel(by message: SBDBaseMessage) -> MessageModel? {
        return self.models.first { $0.message == message || $0.requestID == message.requestID }
    }
    
    func findMessage(by model: MessageModel) -> SBDBaseMessage? {
        return self.findMessage(by: model.message)
    }
    
    func findMessage(by message: SBDBaseMessage) -> SBDBaseMessage? {
        return self.models.first { $0.message == message || $0.requestID == message.requestID }?.message
    }
}

// MARK: - Update
extension MessageControl {
    @discardableResult
    func update(by message: SBDBaseMessage) -> Int {
        return self.update(by: MessageModel(message))
    }
    
    @discardableResult
    func update(by model: MessageModel) -> Int {
        let index = self.models.firstIndex {
            if $0 == model { return true }
            if $0.messageID == model.messageID { return true }
            if $0.requestID == model.requestID { return !$0.requestID.isEmpty }
            
            return false
        }
        
        if let index = index {
            model.params = self.models[index].params
            self.models[index] = model
            
            return index
        }
        else {
            return self.add(by: model)
        }
    }
    
    @discardableResult
    func update(by messages: [SBDBaseMessage]) -> [Int] {
        let models = messages.map { MessageModel($0) }
        return self.update(by: models)
    }
    
    @discardableResult
    func update(by models: [MessageModel]) -> [Int] {
        guard !models.isEmpty else { return [] }
        
        let sortedModels = models.sorted { $0.createdAt < $1.createdAt }
        
        if self.models.isEmpty {
            self.models = sortedModels
            return models.enumerated().map { $0.0 }
        }
        
        guard
            let oldFirst = self.models.first,
            let oldLast = self.models.last,
            let newFirst = sortedModels.first,
            let newLast = sortedModels.last
            else {
                assertionFailure("Message must exist.")
                return []
        }
          
        if oldLast.createdAt < newFirst.createdAt { // Next Message
            return addNext(by: sortedModels)
            
        } else if oldFirst.createdAt > newLast.createdAt { // Previous Message
            return addPrevious(by: sortedModels)
            
        } else { // Event Message or same Message
            
            sortedModels.forEach { self.update(by: $0) }
            return sortedModels.compactMap { self.findIndex(by: $0) }
            
        }
    }
    
    func updatePendingFileMessage(message: SBDFileMessage, params: SBDFileMessageParams) {
        pendingFileMessageParams[message.requestID] = params
    }
}

// MARK: - Add
extension MessageControl {
    func insert(by message: SBDBaseMessage) -> IndexPath? {
        let newModel = MessageModel(message)
        
        if models.count == 0 {
            models.append(newModel)
            
            return IndexPath(row: 0, section: 0)
        }
        
        let firstModelCreatedAt = models.first?.createdAt
        let lastModelCreatedAt = models.last?.createdAt
        
        if newModel.createdAt <= firstModelCreatedAt! {
            models.insert(newModel, at: 0)
            
            return IndexPath(row: 0, section: 0)
        }
        
        if newModel.createdAt >= lastModelCreatedAt! {
            models.append(newModel)
            
            return IndexPath(row: models.count - 1, section: 0)
        }
        
        if newModel.createdAt > firstModelCreatedAt! && newModel.createdAt < lastModelCreatedAt! {
            var foundPosition: Bool = false
            var position = 0
            
            for index in stride(from: 0, to: models.count, by: 1) {
                let modelCreatedAt = models[index].createdAt
                
                if modelCreatedAt > newModel.createdAt {
                    position = index
                    foundPosition = true
                    break
                }
            }
            
            if foundPosition == true {
                models.insert(newModel, at: position)
                
                return IndexPath(row: position, section: 0)
            }
        }
        
        return nil
    }
    
    func insertPendingMessage(by model: MessageModel) -> IndexPath? {
        if models.count == 0 {
            models.append(model)
            
            return IndexPath(row: 0, section: 0)
        }
        
        let firstModelCreatedAt = models.first?.createdAt
        let lastModelCreatedAt = models.last?.createdAt
        
        if model.createdAt <= firstModelCreatedAt! {
            models.insert(model, at: 0)
            
            return IndexPath(row: 0, section: 0)
        }
        
        if model.createdAt >= lastModelCreatedAt! {
            models.append(model)
            
            return IndexPath(row: models.count - 1, section: 0)
        }
        
        if model.createdAt > firstModelCreatedAt! && model.createdAt < lastModelCreatedAt! {
            var foundPosition: Bool = false
            var position = 0
            
            for index in stride(from: 0, to: models.count, by: 1) {
                let modelCreatedAt = models[index].createdAt
                
                if modelCreatedAt > model.createdAt {
                    position = index
                    foundPosition = true
                    break
                }
            }
            
            if foundPosition == true {
                models.insert(model, at: position)
                
                return IndexPath(row: position, section: 0)
            }
        }
        
        return nil
    }
    
    
    func add(by message: SBDBaseMessage) {
        let newModel = MessageModel(message)
        var pos = -1
        for i in stride(from: self.models.count - 1, to: 0, by: -1) {
            let existingCreateAt = self.models[i].createdAt
            let newCreatedAt = newModel.createdAt
            
            if existingCreateAt < newCreatedAt {
                pos = i
                break
            }
        }
        
        if pos == -1 {
            self.models.append(newModel)
        }
    }
    
    @discardableResult
    func add(by model: MessageModel) -> Int {
        
        guard
            let firstModel = self.models.first,
            let lastModel = self.models.last else {
                self.models = [ model ]
                return 0
        }
         
        if firstModel.createdAt > model.createdAt {
            self.models.insert(model, at: 0)
            return 0
        
        } else if lastModel.createdAt < model.createdAt {
            self.models.append(model)
            return self.models.count
        
        } else if let index = models.firstIndex(where: { $0 == model }) {
            assertionFailure("This message must update.")
            return index
        } else {
            models.append(model)
            models.sort { $0.createdAt < $1.createdAt }
            return models.firstIndex(of: model)!
        }
        
    }
    
    @discardableResult
    private func addNext(by models: [MessageModel]) -> [Int] {
        let oldMessageCount = self.models.count
        self.models += models
        return models.enumerated().map { $0.0 + oldMessageCount }
    }
    
    @discardableResult
    private func addPrevious(by models: [MessageModel]) -> [Int] {
        self.models.insert(contentsOf: models, at: 0)
        return models.enumerated().map { $0.0 }
    }
    
}

// MARK: - Delete
extension MessageControl {
     
    func remove(_ model: MessageModel) {
        let count = self.models.count
        
        self.remove(model.requestID)
        
        if count == self.models.count {
            assertionFailure("It should have been removed.")
            self.remove(model.messageID)
        }
        
    }
  
    func remove(_ messageID: Int64) {
        self.models = self.models.filter { $0.messageID != messageID }
    }
  
    func remove(_ requestID: String) {
        self.models = self.models.filter { $0.requestID != requestID }
    }
}

extension MessageControl {
 
    func updateAllModels() {
         
        let comparators = models.enumerated().map {
            ModelComparator(prevModel: self.models[exists: $0.0 - 1],
                            currModel: $0.element,
                            nextModel: self.models[exists: $0.0 + 1])
        }
        
        self.models = comparators.map { $0.updatedModel() }
    }
    
    func updatedModel(index: Int) -> MessageModel {
        let comparator = ModelComparator(prevModel: self.models[exists: index - 1],
                                         currModel: self.models[index],
                                         nextModel: self.models[exists: index + 1])
        
        return comparator.updatedModel()
         
        
    }
}

private struct ModelComparator {
    let prevModel: MessageModel?
    let currModel: MessageModel
    let nextModel: MessageModel?
    
    func updatedModel() -> MessageModel {
        
        if let prevModel = self.prevModel {
            currModel.hasPrevMessage = true
            currModel.isPrevMessageSameDay = !Utils.checkDayChangeDayBetweenOldTimestamp(
                oldTimestamp: prevModel.createdAt,
                newTimestamp: currModel.createdAt)
            currModel.isPrevMessageSameUser = currModel.userID == prevModel.userID
        } else {
            currModel.hasPrevMessage = false
            currModel.isPrevMessageSameDay = false
            currModel.isPrevMessageSameUser = false
        }
        
        if let nextModel = self.nextModel {
            currModel.isNextMessageSameDay =  !Utils.checkDayChangeDayBetweenOldTimestamp(oldTimestamp: currModel.createdAt, newTimestamp: nextModel.createdAt)
            currModel.isNextMessageSameUser = currModel.userID == nextModel.userID
        } else {
            currModel.isNextMessageSameDay = false
            currModel.isNextMessageSameUser = false
        }
        
        return currModel
    }
    
}
