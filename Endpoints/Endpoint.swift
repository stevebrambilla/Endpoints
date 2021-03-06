//
//  Endpoint.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-10.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

// ----------------------------------------------------------------------------
// MARK: - Endpoint

/// Endpoints are used to create one-way bindings from `SignalProducer`s to
/// object properties, typically for binding data to views.
///
/// Signal producers can be bound to Endpoints using:
/// 
/// - `SignalProducer.bind(to: <endpoint>)`
/// - `Property.bind(to: <endpoint>)`
/// - `Endpoint.bind(from: <producer>)`
/// - The ReactiveSwift bind operator (`<~`)
///
/// Endpoints are expected to be exposed by UI classes, so binding a signal
/// producer guarantees that the setter is invoked on the main thread. 
/// Therefore, it's not necessary to call `observe(on: UIScheduler())` on the
/// bound signal producers.
///
/// Endpoints keep a *weak* reference to their targets. If a value is sent to an
/// endpoint whose target reference has been zero'd out, the binding will be
/// terminated.
public struct Endpoint<Value> {
	private typealias Setter = () -> Void
	private let generateSetter: (Value) -> Result<Setter, EndpointError>
	private let before: ((Value) -> Void)?
	private let after: ((Value) -> Void)?

	public init<Target: AnyObject>(_ target: Target, writeValue: @escaping (Target, Value) -> ()) {
		self.generateSetter = { [weak target] value in
			guard let strongTarget = target else { return Result(error: .targetZerod) }
			let setter = { writeValue(strongTarget, value) } // Strongly captures the target
			return Result(value: setter)
		}

		self.before = nil
		self.after = nil
	}

	private init(generator: @escaping (Value) -> Result<Setter, EndpointError>, before: ((Value) -> Void)?, after: ((Value) -> Void)?) {
		self.generateSetter = generator

		self.before = before
		self.after = after
	}

	/// Injects side effects to be performed either before or after setting the 
	/// value. Execution is always on the main thread.
	public func on(before: ((Value) -> Void)? = nil, after: ((Value) -> Void)? = nil) -> Endpoint {
		return Endpoint(generator: generateSetter, before: before, after: after)
	}

	/// Binds `signal` to the endpoint and returns the Disposable that can be
	/// used to cancel the binding.
	@discardableResult
	public func bind(from signal: Signal<Value, NoError>) -> Disposable {
		// Create a signal producer from the signal and bind to it.
		let producer = SignalProducer<Value, NoError> { observer, lifetime in
			let disposable = signal.observe(observer)
			lifetime.observeEnded { disposable?.dispose() }
		}

		return bind(from: producer)
	}

	/// Binds `producer` to the endpoint and returns a Disposable that can be
	/// used to cancel the binding.
	@discardableResult
	public func bind(from producer: SignalProducer<Value, NoError>) -> Disposable {
		return producer
			.promoteError(EndpointError.self)

			// Create a Setter with the strongly captured target.
			// If an error occurs (eg. target was zero'd), then the binding terminates.
			.attemptMap { [generate = self.generateSetter] value in
				return generate(value).map { setter in (value, setter) }
			}

			// Execute the setter on the UI thread.
			.observe(on: UIScheduler())
			.startWithResult { [before = self.before, after = self.after] result in
				guard let (value, setter) = result.value else { return }

				before?(value)
				setter()
				after?(value)
			}
	}
}

private enum EndpointError: Error {
	case targetZerod
}

// ----------------------------------------------------------------------------
// MARK: - Binding Operator

/// Binds `producer` to `endpoint` and returns a Disposable that can be used
/// to cancel the binding.
@discardableResult
public func <~ <T>(endpoint: Endpoint<T>, producer: SignalProducer<T, NoError>) -> Disposable {
	return endpoint.bind(from: producer)
}

/// Binds `property` to `endpoint` and returns a Disposable that can be used
/// to cancel the binding.
@discardableResult
public func <~ <T, P: PropertyProtocol>(endpoint: Endpoint<T>, property: P) -> Disposable where P.Value == T {
	return endpoint.bind(from: property.producer)
}
