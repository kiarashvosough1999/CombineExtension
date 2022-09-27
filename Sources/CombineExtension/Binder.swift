//
//  Binder.swift
//  
//
//  Created by Kiarash Vosough on 9/27/22.
//

import Foundation
import Combine

public final class Binder<Input>: Subscriber {

    public typealias Input = Input
    public typealias Failure = Never

    private var completed: Bool = false
    private var subscription: Subscription?
    private let binderBlock: (Input) -> Void

    public var combineIdentifier: CombineIdentifier
    public var cancelable: Cancellable { subscription! }

    public init(_ binderBlock: @escaping (Input) -> Void) {
        self.binderBlock = binderBlock
        self.combineIdentifier = CombineIdentifier()
    }

    public func receive(subscription: Subscription) {
        if self.subscription == nil && self.completed == false {
            self.subscription = subscription
            subscription.request(.unlimited)
        }
    }

    public func receive(_ input: Input) -> Subscribers.Demand {
        self.binderBlock(input)
        return .unlimited
    }

    public func receive(completion: Subscribers.Completion<Never>) {
        self.subscription = nil
        self.completed = true
    }
}

extension Publisher where Failure == Never {
    public func assign(to binder: Binder<Output>) -> Cancellable {
        subscribe(binder)
        return binder.cancelable
    }
}
