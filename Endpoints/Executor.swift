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
/// Actions can be bound to Executors using the `bindTo()` method.
///
/// If the Executor's trigger `Payload` type doesn't match the Action's `Input`
/// type, a transform function can be provided to map `Payloads` to `Inputs`.
public struct Executor<Payload> {
	private let enabledEndpoint: Endpoint<Bool>?
	private let trigger: Trigger<Payload>
	private let afterEnabled: (Bool -> ())?

	public init<T>(enabled: Endpoint<Bool>? = nil, trigger producer: SignalProducer<T, NoError>, transform: T -> Payload) {
		self.init(enabled: enabled, trigger: .SignalProducer(producer), transform: transform)
	}

	public init(enabled: Endpoint<Bool>? = nil, trigger producer: SignalProducer<Payload, NoError>) {
		self.init(enabled: enabled, trigger: .SignalProducer(producer))
	}

	public init<T>(enabled: Endpoint<Bool>? = nil, trigger signal: Signal<T, NoError>, transform: T -> Payload) {
		self.init(enabled: enabled, trigger: .Signal(signal), transform: transform)
	}

	public init(enabled: Endpoint<Bool>? = nil, trigger signal: Signal<Payload, NoError>) {
		self.init(enabled: enabled, trigger: .Signal(signal))
	}

	// "Designated" initializer without transform. Can supply `afterEnabled` closure.
	private init(enabled: Endpoint<Bool>?, trigger: Trigger<Payload>, afterEnabled: (Bool -> ())? = nil) {
		self.enabledEndpoint = enabled
		self.trigger = trigger
		self.afterEnabled = afterEnabled
	}

	// "Designated" initializer with transform.
	private init<T>(enabled: Endpoint<Bool>?, trigger: Trigger<T>, transform: T -> Payload) {
		self.enabledEndpoint = enabled
		self.trigger = trigger.map(transform)
		self.afterEnabled = nil
	}

	/// Maps each trigger payload from the Executor to a new value.
	public func mapPayloads<U>(transform: Payload -> U) -> Executor<U> {
		return Executor<U>(enabled: enabledEndpoint, trigger: trigger, transform: transform)
	}

	/// Ignores all trigger payloads by sending Void instead.
	public func ignorePayloads() -> Executor<Void> {
		return mapPayloads { _ in () }
	}

	/// Injects side effects to be performed after the `enabled` Endpoint is
	/// updated.
	public func on(enabled enabled: Bool -> ()) -> Executor {
		return Executor(enabled: enabledEndpoint, trigger: trigger, afterEnabled: enabled)
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
		let disposable = CompositeDisposable()

		if let enabledEndpoint = enabledEndpoint {
			disposable += enabledEndpoint
				.on(after: afterEnabled)
				.bind(action.enabled.producer)
		}

		disposable += trigger.observe { payload in
			let input = transform(payload)
			action.apply(input).start()
		}

		return disposable
	}
}

private enum Trigger<Payload> {
	case Signal(ReactiveCocoa.Signal<Payload, NoError>)
	case SignalProducer(ReactiveCocoa.SignalProducer<Payload, NoError>)

	private func map<U>(transform: Payload -> U) -> Trigger<U> {
		switch self {
		case let .Signal(signal):
			return .Signal(signal.map(transform))

		case let .SignalProducer(producer):
			return .SignalProducer(producer.map(transform))
		}
	}

	private func observe(next: Payload -> ()) -> Disposable? {
		switch self {
		case let .Signal(signal):
			return signal.observeNext { next($0) }

		case let .SignalProducer(producer):
			return producer.startWithNext { next($0) }
		}
	}
}
