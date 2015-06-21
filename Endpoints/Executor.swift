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

/// Executors are used to attach Actions to objects that trigger execution 
/// events, typically used to bind to UI controls. Executors also bind the 
/// `enabled` state of Actions to an Endpoint that is exposed by the executor's
/// owner.
///
/// Actions can be bound to Executors using the `bind()` method, or the 
/// ReactiveCocoa bind operator (`<~`).
///
/// If the Executor's Event type doesn't match the Action's Input type, a 
/// transform function can be provided to map Events to Inputs.
public struct Executor<Event> {
	private let enabledEndpoint: Endpoint<Bool>
	private let executionEventProducer: SignalProducer<Event, NoError>

	public init<T>(enabled: Endpoint<Bool>, eventProducer: SignalProducer<T, NoError>, transform: T -> Event) {
		self.enabledEndpoint = enabled
		self.executionEventProducer = eventProducer |> map(transform)
	}

	public init(enabled: Endpoint<Bool>, eventProducer: SignalProducer<Event, NoError>) {
		self.enabledEndpoint = enabled
		self.executionEventProducer = eventProducer
	}

	/// Maps each event from the Executor to a new value.
	public func mapEvents<T>(transform: Event -> T) -> Executor<T> {
		return Executor<T>(enabled: enabledEndpoint, eventProducer: executionEventProducer, transform: transform)
	}

	/// Ignores all event values by sending Void instead.
	public func ignoreEvents() -> Executor<()> {
		return mapEvents { _ in () }
	}

	/// Binds `action` to `executor` so the Action is executed whenever the
	/// Executor sends an event. The value of the execution event is used as the
	/// input to the Action.
	///
	/// Returns a Disposable that can be used to cancel the binding.
	public func bind<Output, Error>(action: Action<Event, Output, Error>) -> Disposable {
		return bind(action, transform: { $0 })
	}

	/// Binds `action` to `executor` so the Action is executed whenever the
	/// Executor sends an event. The value of the execution event is transformed
	/// by applying `transform` before being used as the input to the Action.
	///
	/// Returns a Disposable that can be used to cancel the binding.
	public func bind<Input, Output, Error>(action: Action<Input, Output, Error>, transform: Event -> Input) -> Disposable {
		let enabledDisposable = enabledEndpoint.bind(action.enabled.producer)

		let eventsDisposable = executionEventProducer.start(next: { sender in
			let input = transform(sender)
			action.apply(input).start()
		})

		return CompositeDisposable([enabledDisposable, eventsDisposable])
	}
}

// ----------------------------------------------------------------------------
// MARK: - Binding Operator


/// Binds `action` to `executor` so the Action is executed whenever the Executor
/// sends an event. The value of the execution event is used as the input to the
/// Action.
///
/// Returns a Disposable that can be used to cancel the binding.
public func <~ <Event, Output, Error>(executor: Executor<Event>, action: Action<Event, Output, Error>) -> Disposable {
	return executor.bind(action)
}
