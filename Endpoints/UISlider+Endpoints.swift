//
//  UISlider+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-14.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit
import ReactiveCocoa

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UISlider {
	/// An `Endpoint` to bind a `SignalProducer` to the `UISlider`'s
	/// `value` value, optionally with animation. The `Endpoint` accepts
	/// a tuple where the Float is the value, and the Bool determines whether
	/// the change is animated.
	public var animatedValueEndpoint: Endpoint<(Float, Bool)> {
		return Endpoint(self) { slider, tuple in slider.setValue(tuple.0, animated: tuple.1) }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UISlider`'s
	/// `value` value without animation.
	public var valueEndpoint: Endpoint<Float> {
		return Endpoint(self) { $0.value = $1 }
	}
}

// ----------------------------------------------------------------------------
// MARK: - Signal Producers

extension UISlider {
	/// Returns a signal producer that sends the `value` each time the value is
	/// changed.
	///
	/// Note that the `UISlider` is weakly referenced by the `SignalProducer`.
	/// If the `UISlider` is deallocated before the signal producer is started
	/// it will complete immediately. Otherwise this producer will not terminate
	/// naturally, so it must be explicitly disposed to avoid leaks.
	///
	/// The current value of `value` is sent immediately upon starting the
	/// signal producer.
	public func valueProducer() -> SignalProducer<Float, NoError> {
		let valueChanges = controlEventsProducer(UIControlEvents.ValueChanged)
			.map { sender -> Float in
				if let slider = sender as? UISlider {
					return slider.value
				} else {
					fatalError("Expected sender to be an instance of UISlider, got: \(sender).")
				}
			}
		
		return SignalProducer(value: value).concat(valueChanges)
	}
}
