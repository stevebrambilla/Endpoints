//
//  UIControl+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-13.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit
import ReactiveCocoa

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UIControl {
	/// An `Endpoint` to bind a `SignalProducer` to the `UIControl`'s `enabled` 
	/// value.
	public var enabledEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.enabled = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIControl`'s
	/// `highlighted` value.
	public var highlightedEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.highlighted = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIControl`'s
	/// `selected` value.
	public var selectedEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.selected = $1 }
	}
}

// ----------------------------------------------------------------------------
// MARK: - Signal Producers

extension UIControl {
	/// Returns a signal producer that sends the `sender` each time an action
	/// message is sent for any of the `events`.
	///
	/// Note that the `UIControl` is weakly referenced by the `SignalProducer`.
	/// If the `UIControl` is deallocated before the signal producer is started
	/// it will complete immediately. Otherwise this producer will not terminate
	/// naturally, so it must be explicitly disposed to avoid leaks.
	public func controlEventsProducer(events: UIControlEvents) -> SignalProducer<AnyObject, NoError> {
		return SignalProducer { [weak self] observer, disposable in
			let target = ObjCTarget() { sender in
				sendNext(observer, sender)
			}

			if let control = self {
				control.addTarget(target, action: target.selector, forControlEvents: events)

				disposable.addDisposable {
					self?.removeTarget(target, action: target.selector, forControlEvents: events)
				}
			} else {
				sendCompleted(observer)
			}
		}
	}
}
