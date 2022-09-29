//
//  Publisher++WeakAssign.swift
//  
//
//  Created by Kiarash Vosough on 9/29/22.
//

import Combine

extension Publisher where Failure == Never {

    public func weakAssign<Root>(
        to keyPath: ReferenceWritableKeyPath<Root, Self.Output>,
        on object: Root
    ) -> AnyCancellable where Root: AnyObject {
        self.sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
