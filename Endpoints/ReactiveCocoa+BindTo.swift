//
//  ReactiveCocoa+BindTo.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-10-22.
//  Copyright © 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension SignalProducerType where Error == NoError {
	/// Binds the signal producer to `endpoint` and returns a Disposable that
	/// can be used to cancel the binding.
	public func bindTo(endpoint: Endpoint<Value>) -> Disposable {
		return endpoint.bind(producer)
	}
}

extension PropertyType {
	/// Binds the property to `endpoint` and returns a Disposable that
	/// can be used to cancel the binding.
	public func bindTo(endpoint: Endpoint<Value>) -> Disposable {
		return endpoint.bind(producer)
	}
}
