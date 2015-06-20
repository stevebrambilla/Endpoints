//
//  Endpoint.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-10.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveCocoa

// ----------------------------------------------------------------------------
// MARK: - Endpoint

/// Endpoints are used to create one-way bindings from `SignalProducer`s to
/// object properties, typically for binding data to views.
///
/// Signal producers can be bound to Endpoints using the `bind()` method, or
/// the ReactiveCocoa bind operator (`<~`).
///
/// Endpoints are expected to be exposed by UI classes, so binding a signal
/// producer guarantees that the setter is invoked on the main thread. 
/// Therefore, it's not necessary to call `observeOn(UIScheduler())` on the 
/// bound signal producers.
///
/// Endpoints keep a *weak* reference to their targets. If a value is sent to an
/// endpoint whose target reference has been zero'd out the signal will
/// automatically complete, cancelling the binding.
public struct Endpoint<Value> {
	private let createSetter: Value -> (() -> ())?

	public init<Target: AnyObject>(_ target: Target, writeValue: (Target, Value) -> ()) {
		weak var weakTarget = target

		self.createSetter = { value in
			if let target = weakTarget {
				return { writeValue(target, value) } // Strongly captures the target
			}
			return nil
		}
	}

	/// Binds `producer` to `endpoint` and returns a Disposable that can be
	/// used to cancel the binding.
	public func bind(producer: SignalProducer<Value, NoError>) -> Disposable {
		return producer
			// Create a () -> () setter closure with the target and view strongly captured.
			|> map { self.createSetter($0) }
			// Stop if the closure couldn't be created -- the target ref has been zero'd.
			|> takeWhile { $0 != nil }
			// Execute the setter on the UI thread.
			|> observeOn(UIScheduler())
			|> start(next: { setter in setter?() })
	}
}

// ----------------------------------------------------------------------------
// MARK: - Binding Operator

/// Binds `producer` to `endpoint` and returns a Disposable that can be used
/// to cancel the binding.
public func <~ <T>(endpoint: Endpoint<T>, producer: SignalProducer<T, NoError>) -> Disposable {
	return endpoint.bind(producer)
}
