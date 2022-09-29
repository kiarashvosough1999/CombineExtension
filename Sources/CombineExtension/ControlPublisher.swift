//
//  ControlPublisher.swift
//  
//
//  Created by Kiarash Vosough on 9/27/22.
//

import Combine
#if os(macOS)
import Cocoa
typealias Control = NSControl
#elseif os(iOS) || os(tvOS)
import UIKit
typealias Control = UIControl
#endif

// MARK: - Abstraction

protocol ControlPublisher: Control {}

extension ControlPublisher {
    #if os(macOS)
    func actionPublisher() -> Control.InteractionPublisher<Self> {
        return InteractionPublisher(control: self)
    }
    #elseif os(iOS) || os(tvOS)
    func publisher(for event: Control.Event) -> Control.InteractionPublisher<Self> {
        return InteractionPublisher(control: self, event: event)
    }
    #endif
}

// MARK: - Make Control Publisher

extension Control: ControlPublisher {

    
    // MARK: - Errors

    public enum InteractionPublisherError: Error {
        case objectFoundNil
    }

    // MARK: - Publisher

    internal struct InteractionPublisher<C: Control>: Publisher {

        internal typealias Output = C
        internal typealias Failure = InteractionPublisherError
        private weak var control: C?
        
        #if os(iOS) || os(tvOS)
        private let event: Control.Event

        internal init(control: C, event: Control.Event) {
            self.control = control
            self.event = event
        }
        #elseif os(macOS)
        internal init(control: C) {
            self.control = control
        }
        #endif

        internal func receive<S>(subscriber: S) where S : Subscriber, InteractionPublisherError == S.Failure, C == S.Input {
            guard let control = control else {
                subscriber.receive(completion: .failure(.objectFoundNil))
                return
            }

            #if os(iOS) || os(tvOS)
            let subscription = InteractionSubscription(
                subscriber: subscriber,
                control: control,
                event: event
            )
            #elseif os(macOS)
            let subscription = InteractionSubscription(
                subscriber: subscriber,
                control: control
            )
            #endif
            subscriber.receive(subscription: subscription)
        }
    }

    // MARK: - Subscription

    internal class InteractionSubscription<S: Subscriber, C: Control>: Subscription where S.Input == C {

        private let subscriber: S?
        private weak var control: C?
        
        #if os(iOS) || os(tvOS)
        private let event: Control.Event

        internal init(subscriber: S,
             control: C?,
             event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            self.event = event
            self.control?.addTarget(self, action: #selector(handleEvent), for: event)
        }
        #elseif os(macOS)
        internal init(
            subscriber: S,
             control: C?
        ) {
            self.subscriber = subscriber
            self.control = control
            self.control?.target = self
            self.control?.action = #selector(handleEvent)
        }
        #endif

        @objc func handleEvent(_ sender: Control) {
            guard let control = self.control else {
                return
            }
            _ = self.subscriber?.receive(control)
        }
        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            #if os(macOS)
            self.control?.target = nil
            self.control?.action = nil
            #elseif os(iOS) || os(tvOS)
            self.control?.removeTarget(self, action: #selector(handleEvent), for: self.event)
            #endif
            self.control = nil
        }
    }
}
