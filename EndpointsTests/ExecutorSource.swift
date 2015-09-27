//
//  ExecutorSource.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-19.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import Endpoints
import ReactiveCocoa

class ExecutorSource {
	private(set) var enabled = false

	let (eventSignal, eventObserver) = Signal<Int, NoError>.pipe()

	var executor: Executor<Int> {
		let enabled = Endpoint(self) { $0.enabled = $1 }

		let producer = SignalProducer { observer, _ in
			eventSignal.observe(observer)
		}

		return Executor(enabled: enabled, trigger: producer)
	}

	private var count = 0
	func trigger() {
		sendNext(eventObserver, count)
		count++
	}
}
