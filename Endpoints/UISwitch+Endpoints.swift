//
//  UISwitch+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-14.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit
import ReactiveCocoa

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UISwitch {
	/// An `Endpoint` to bind a `SignalProducer` to the `UISwitch`'s
	/// `on` value, optionally with animation. The `Endpoint` accepts
	/// a tuple where the first Bool is the value, and the second Bool 
	/// determines whether the change is animated.
	public var animatedOnEndpoint: Endpoint<(Bool, Bool)> {
		return Endpoint(self) { theSwitch, tuple in theSwitch.setOn(tuple.0, animated: tuple.1) }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UISwitch`'s `on`
	/// value without animation.
	public var onEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.on = $1 }
	}
}

// ----------------------------------------------------------------------------
// MARK: - Signal Producers

extension UISwitch {
	/// Returns a signal producer that sends the `on` each time the value is
	/// changed.
	///
	/// Note that the `UISlider` is strongly referenced by the
	/// `SignalProducer`. This producer will not terminate naturally, so it must
	/// be disposed or interrupted to avoid leaks.
	///
	/// The current value of `on` is sent immediately upon starting the signal
	/// producer.
	public var onProducer: SignalProducer<Bool, NoError> {
		// Current value lookup deferred until producer is started.
		let currentValue = SignalProducer<Bool, NoError> { observer, _ in
			sendNext(observer, self.on)
			sendCompleted(observer)
		}

		let onChanges = controlEventsProducer(UIControlEvents.ValueChanged)
			.map { sender -> Bool in
				if let theSwitch = sender as? UISwitch {
					return theSwitch.on
				} else {
					fatalError("Expected sender to be an instance of UISwitch, got: \(sender).")
				}
			}

		return currentValue.concat(onChanges)
	}
}
