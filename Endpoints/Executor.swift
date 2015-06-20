//
//  Executor.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-19.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct Executor<Event> {
	private let enabledEndpoint: Endpoint<Bool>
	private let executionEventProducer: SignalProducer<Event, NoError>

	public init(enabled: Endpoint<Bool>, eventProducer: SignalProducer<Event, NoError>) {
		self.enabledEndpoint = enabled
		self.executionEventProducer = eventProducer
	}

	public func bind<Output, Error>(action: Action<Event, Output, Error>) -> Disposable {
		return bind(action, transform: { $0 })
	}

	public func bind<Input, Output, Error>(action: Action<Input, Output, Error>, transform: Event -> Input) -> Disposable {
		let enabledDisposable = enabledEndpoint.bind(action.enabled.producer)

		let eventsDisposable = executionEventProducer.start(next: { sender in
			let input = transform(sender)
			action.apply(input).start()
		})

		return CompositeDisposable([enabledDisposable, eventsDisposable])
	}
}

public func <~ <Input, Output, Error>(executor: Executor<Input>, action: Action<Input, Output, Error>) -> Disposable {
	return executor.bind(action)
}
