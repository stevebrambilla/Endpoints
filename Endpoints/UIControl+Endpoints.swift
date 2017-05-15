//
//  UIControl+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-13.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UIControl {
	/// An `Endpoint` to bind a `SignalProducer` to the `UIControl`'s `enabled` 
	/// value.
	public var enabledEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.isEnabled = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIControl`'s
	/// `highlighted` value.
	public var highlightedEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.isHighlighted = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIControl`'s
	/// `selected` value.
	public var selectedEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.isSelected = $1 }
	}
}

// ----------------------------------------------------------------------------
// MARK: - Signal Producers

extension UIControl {
	/// Returns a signal producer that sends the `sender` each time an action
	/// message is sent for any of the `events`.
	///
	/// Note that the `UIControl` is strongly referenced by the
	/// `SignalProducer`. This producer will not terminate naturally, so it must
	/// be disposed or interrupted to avoid leaks.
	public func controlEventsProducer(_ events: UIControlEvents) -> SignalProducer<AnyObject, NoError> {
		return SignalProducer { observer, disposable in
			let target = ObjCTarget() { sender in
				observer.send(value: sender)
			}

			self.addTarget(target, action: target.selector, for: events)

			disposable.add {
				self.removeTarget(target, action: target.selector, for: events)
			}
		}
	}
}
