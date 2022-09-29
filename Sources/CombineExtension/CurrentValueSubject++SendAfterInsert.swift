//
//  CurrentValueSubject++SendAfterInsert.swift
//  
//
//  Created by Kiarash Vosough on 9/29/22.
//

import Combine

extension CurrentValueSubject where Output: RangeReplaceableCollection, Failure == Never {

    public func sendAfterInsert(element: Output.Element, at index: Output.Index) {
        var newSequence = self.value
        newSequence.insert(element, at: index)
        self.send(newSequence)
    }
}

