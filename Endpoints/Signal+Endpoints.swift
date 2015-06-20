//
//  Signal+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-20.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveCocoa

/// Creates a SignalProducer from a Signal and prepends an initial value to the
/// stream, which is sent immediately when the SignalProducer is started.
public func withInitialValue<T, E>(initialValue: T)(signal: Signal<T, E>) -> SignalProducer<T, E> {
	return SignalProducer { observer, disposable in
		sendNext(observer, initialValue)
		signal.observe(observer)
	}
}
