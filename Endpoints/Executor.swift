//
//  Executor.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-19.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveCocoa

// ----------------------------------------------------------------------------
// MARK: - Executor

/// Executors are used to attach Actions to objects that trigger executions
/// (like buttons). They are typically used to bind actions to UI controls.
/// Executors also bind the `enabled` state of Actions to an Endpoint that is
/// exposed by the executor's owner.
///
/// Actions can be bound to Executors using the `bind()` method, or the 
/// ReactiveCocoa bind operator (`<~`).
///
/// If the Executor's trigger `Payload` type doesn't match the Action's `Input`
/// type, a transform function can be provided to map `Payloads` to `Inputs`.
public struct Executor<Payload> {
	private let enabledEndpoint: Endpoint<Bool>
	private let triggerEvents: SignalProducer<Payload, NoError>

	public init<T>(enabled: Endpoint<Bool>, trigger: SignalProducer<T, NoError>, transform: T -> Payload) {
		self.enabledEndpoint = enabled
		self.triggerEvents = trigger.map(transform)
	}

	public init(enabled: Endpoint<Bool>, trigger: SignalProducer<Payload, NoError>) {
		self.enabledEndpoint = enabled
		self.triggerEvents = trigger
	}

	/// Maps each trigger payload from the Executor to a new value.
	public func mapPayloads<U>(transform: Payload -> U) -> Executor<U> {
		return Executor<U>(enabled: enabledEndpoint, trigger: triggerEvents, transform: transform)
	}

	/// Ignores all trigger payloads by sending Void instead.
	public func ignorePayloads() -> Executor<Void> {
		return mapPayloads { _ in () }
	}

	/// Binds `executor` to `action`, so the Action is executed whenever the
	/// Executor sends an event. The value of the execution event is used as the
	/// input to the Action.
	///
	/// Returns a Disposable that can be used to cancel the binding.
	public func bindTo<Output, Error>(action: Action<Payload, Output, Error>) -> Disposable {
		return bindTo(action, transform: { $0 })
	}

	/// Binds `executor` to `action`, so the Action is executed whenever the
	/// Executor sends an event. The value of the execution event is transformed
	/// by applying `transform` before being used as the input to the Action.
	///
	/// Returns a Disposable that can be used to cancel the binding.
	public func bindTo<Input, Output, Error>(action: Action<Input, Output, Error>, transform: Payload -> Input) -> Disposable {
		let enabledDisposable = enabledEndpoint.bind(action.enabled.producer)

		let eventsDisposable = triggerEvents.startWithNext { payload in
			let input = transform(payload)
			action.apply(input).start()
		}

		return CompositeDisposable([enabledDisposable, eventsDisposable])
	}
}
