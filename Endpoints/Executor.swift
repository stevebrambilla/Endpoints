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
/// transform function can be provided to map Events to Inputs:
///
/// Example:
///
///     button.executor <~ action |> ignoreEvents
///
public struct Executor<Event> {
	private let enabledEndpoint: Endpoint<Bool>
	private let executionEventProducer: SignalProducer<Event, NoError>

	public init(enabled: Endpoint<Bool>, eventProducer: SignalProducer<Event, NoError>) {
		self.enabledEndpoint = enabled
		self.executionEventProducer = eventProducer
	}

	/// Binds `action` to `executor` so the Action is executed whenever the
	/// Executor sends an event. The value of the execution event is used as the
	/// input to the Action.
	///
	/// Returns a Disposable that can be used to cancel the binding.
	public func bind<Output, Error>(action: Action<Event, Output, Error>) -> Disposable {
		return bind(action, transform: { $0 })
	}

	/// Binds `actionAdaptor` to `executor` so the adapted Action is executed
	/// whenever the Executor sends an event. The values of the execution events
	/// are transformed by the ActionAdaptor before being used as the input to
	/// the Action.
	///
	/// Returns a Disposable that can be used to cancel the binding.
	public func bind<Input, Output, Error>(adaptor: ActionAdaptor<Event, Input, Output, Error>) -> Disposable {
		return bind(adaptor.action, transform: adaptor.transform)
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
// MARK: - Adapting Actions

/// Used to adapt an Action to an Executor's Event type by transforming the
/// Event type to an Action's Input type.
public struct ActionAdaptor<Event, Input, Output, Error: ErrorType> {
	internal let action: Action<Input, Output, Error>
	internal let transform: Event -> Input

	public init(action: Action<Input, Output, Error>, transform: Event -> Input) {
		self.action = action
		self.transform = transform
	}
}

/// Returns an ActionAdaptor that transforms Events to an Action's Input type.
public func |> <Event, Input, Output, Error: ErrorType>(action: Action<Input, Output, Error>, @noescape transform: Action<Input, Output, Error> -> ActionAdaptor<Event, Input, Output, Error>) -> ActionAdaptor<Event, Input, Output, Error> {
	return transform(action)
}

/// Ignores events for Actions that do not take any input.
public func ignoreInput<Event, Output, Error: ErrorType>(action: Action<(), Output, Error>) -> ActionAdaptor<Event, (), Output, Error> {
	return ActionAdaptor(action: action) { _ in () }
}

/// Maps events to the Action's Input type.
public func mapInput<Event, Input, Output, Error: ErrorType>(transform: Event -> Input)(action: Action<Input, Output, Error>) -> ActionAdaptor<Event, Input, Output, Error> {
	return ActionAdaptor(action: action, transform: transform)
}

// ----------------------------------------------------------------------------
// MARK: - Binding Operator

/// Binds `actionAdaptor` to `executor` so the adapted Action is executed
/// whenever the Executor sends an event. The values of the execution events are
/// transformed by the ActionAdaptor before being used as the input to the 
/// Action.
///
/// Returns a Disposable that can be used to cancel the binding.
public func <~ <Event, Input, Output, Error>(executor: Executor<Event>, actionAdaptor: ActionAdaptor<Event, Input, Output, Error>) -> Disposable {
	return executor.bind(actionAdaptor)
}

/// Binds `action` to `executor` so the Action is executed whenever the Executor
/// sends an event. The value of the execution event is used as the input to the
/// Action.
///
/// Returns a Disposable that can be used to cancel the binding.
public func <~ <Event, Output, Error>(executor: Executor<Event>, action: Action<Event, Output, Error>) -> Disposable {
	return executor.bind(action)
}
