//
//  Signal+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-20.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveSwift

extension SignalProtocol {
	/// Creates a SignalProducer from a Signal and prepends an initial value to
	/// the stream, which is sent immediately when the SignalProducer is 
	/// started.
	public func withInitialValue(_ initialValue: Value) -> SignalProducer<Value, Error> {
		return SignalProducer { observer, disposable in
			observer.send(value: initialValue)
			disposable += self.signal.observe(observer)
		}
	}
}
