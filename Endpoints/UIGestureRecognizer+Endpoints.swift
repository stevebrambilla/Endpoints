//
//  UIGestureRecognizer+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-10-21.
//  Copyright © 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveCocoa

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UIGestureRecognizer {
	/// An `Endpoint` to bind a `SignalProducer` to the `UIGestureRecognizer`'s
	/// `enabled` value.
	public var enabledEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.enabled = $1 }
	}
}

// ----------------------------------------------------------------------------
// MARK: - Signal Producers

extension UIGestureRecognizer {
	/// Returns a signal producer that sends the gesture recognizer each time
	/// an action message is sent by the gesture recognizer.
	///
	/// Note that the `UIGestureRecognizer` is weakly referenced by the
	/// `SignalProducer`. If the `UIGestureRecognizer` is deallocated before the
	/// signal producer is started, it will complete immediately. Otherwise this
	/// producer will not terminate naturally, so it must be explicitly disposed
	/// to avoid leaks.
	public var gestureEventsProducer: SignalProducer<UIGestureRecognizer, NoError> {
		return SignalProducer { [weak self] observer, disposable in
			let target = ObjCTarget() { target in
				guard let gestureRecognizer = target as? UIGestureRecognizer else { return }
				sendNext(observer, gestureRecognizer)
			}

			if let gestureRecognizer = self {
				gestureRecognizer.addTarget(target, action: target.selector)

				disposable.addDisposable {
					self?.removeTarget(target, action: target.selector)
				}
			} else {
				sendCompleted(observer)
			}
		}
	}

	/// Returns a signal producer that sends the gesture recognizer each time
	/// the gesture recognizer recognizes its gesture.
	///
	/// Note that the `UIGestureRecognizer` is weakly referenced by the
	/// `SignalProducer`. If the `UIGestureRecognizer` is deallocated before the
	/// signal producer is started, it will complete immediately. Otherwise this
	/// producer will not terminate naturally, so it must be explicitly disposed
	/// to avoid leaks.
	public var recognizedEventsProducer: SignalProducer<UIGestureRecognizer, NoError> {
		return gestureEventsProducer.filter { $0.state == .Recognized }
	}
}

// ----------------------------------------------------------------------------
// MARK: - Executor

extension UIGestureRecognizer {
	/// Returns an Exector that executes an Action when the UIGestureRecognizer
	/// is recognized, and binds its `enabled` value to the Action's.
	public var executor: Executor<UIGestureRecognizer> {
		return Executor(enabled: enabledEndpoint, trigger: recognizedEventsProducer)
	}
}
