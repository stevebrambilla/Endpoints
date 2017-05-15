//
//  ReactiveSwift+BindTo.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-10-22.
//  Copyright © 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

extension SignalProtocol where Error == NoError {
	/// Binds the signal to `endpoint` and returns a Disposable that can be used
 	/// to cancel the binding.
	public func bindTo(_ endpoint: Endpoint<Value>) -> Disposable {
		return endpoint.bind(signal)
	}

	/// Binds the signal to `endpoint` and returns a Disposable that can be used
	/// to cancel the binding.
	///
	/// This overload maps a non-optional signal to an optional endpoint.
	public func bindTo(_ endpoint: Endpoint<Value?>) -> Disposable {
		let optionalSignal = signal.map(Optional.init)
		return endpoint.bind(optionalSignal)
	}
}

extension SignalProducerProtocol where Error == NoError {
	/// Binds the signal producer to `endpoint` and returns a Disposable that
	/// can be used to cancel the binding.
	public func bindTo(_ endpoint: Endpoint<Value>) -> Disposable {
		return endpoint.bind(producer)
	}

	/// Binds the signal producer to `endpoint` and returns a Disposable that
	/// can be used to cancel the binding.
	///
	/// This overload maps a non-optional producer to an optional endpoint.
	public func bindTo(_ endpoint: Endpoint<Value?>) -> Disposable {
		let optionalProducer = producer.map(Optional.init)
		return endpoint.bind(optionalProducer)
	}
}

extension PropertyProtocol {
	/// Binds the property to `endpoint` and returns a Disposable that
	/// can be used to cancel the binding.
	public func bindTo(_ endpoint: Endpoint<Value>) -> Disposable {
		return producer.bindTo(endpoint)
	}

	/// Binds the property to `endpoint` and returns a Disposable that
	/// can be used to cancel the binding.
	///
	/// This overload binds a non-optional property to an optional endpoint.
	public func bindTo(_ endpoint: Endpoint<Value?>) -> Disposable {
		return producer.bindTo(endpoint)
	}
}
