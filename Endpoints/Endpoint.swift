//
//  Endpoint.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-10.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

// ----------------------------------------------------------------------------
// MARK: - Endpoint

/// Endpoints are used to create one-way bindings from `SignalProducer`s to
/// object properties, typically for binding data to views.
///
/// Signal producers can be bound to Endpoints using:
/// 
/// - `SignalProducer.bindTo(<endpoint>)`
/// - `Property.bindTo(<endpoint>)`
/// - `Endpoint.bind(<producer>)`
/// - The ReactiveCocoa bind operator (`<~`)
///
/// Endpoints are expected to be exposed by UI classes, so binding a signal
/// producer guarantees that the setter is invoked on the main thread. 
/// Therefore, it's not necessary to call `observeOn(UIScheduler())` on the 
/// bound signal producers.
///
/// Endpoints keep a *weak* reference to their targets. If a value is sent to an
/// endpoint whose target reference has been zero'd out, the binding will be
/// terminated.
public struct Endpoint<Value> {
	private typealias Setter = () -> ()
	private let generateSetter: Value -> Result<Setter, EndpointError>

	public init<Target: AnyObject>(_ target: Target, writeValue: (Target, Value) -> ()) {
		self.generateSetter = { [weak target] value in
			guard let strongTarget = target else { return Result(error: .TargetZerod) }
			let setter = { writeValue(strongTarget, value) } // Strongly captures the target
			return Result(value: setter)
		}
	}

	/// Binds `producer` to `endpoint` and returns a Disposable that can be
	/// used to cancel the binding.
	public func bind(producer: SignalProducer<Value, NoError>) -> Disposable {
		return producer
			.promoteErrors(EndpointError)

			// Create a Setter with the strongly captured target.
			// If an error occurs (eg. target was zero'd), then the binding terminates.
			.attemptMap(self.generateSetter)

			// Execute the setter on the UI thread.
			.observeOn(UIScheduler())
			.startWithNext { setter in setter() }
	}
}

private enum EndpointError: ErrorType {
	case TargetZerod
}

// ----------------------------------------------------------------------------
// MARK: - Binding Operator

/// Binds `producer` to `endpoint` and returns a Disposable that can be used
/// to cancel the binding.
public func <~ <T>(endpoint: Endpoint<T>, producer: SignalProducer<T, NoError>) -> Disposable {
	return endpoint.bind(producer)
}

/// Binds `property` to `endpoint` and returns a Disposable that can be used
/// to cancel the binding.
public func <~ <T, P: PropertyType where P.Value == T>(endpoint: Endpoint<T>, property: P) -> Disposable {
	return endpoint.bind(property.producer)
}
