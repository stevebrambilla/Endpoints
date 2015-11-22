//
//  NSNotificationCenter+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-11-22.
//  Copyright © 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveCocoa

// ----------------------------------------------------------------------------
// MARK: - Signal Producers

extension NSNotificationCenter {
	/// Returns a signal producer that sends notifications each time the 
	/// notification sender sends a notification named `name` from the object 
	/// `object`, if one is provided.
	///
	/// Note that the `NSNotificationCenter` is strongly referenced by the
	/// `SignalProducer`. This producer will not terminate naturally, so it must
	/// be disposed of or interrupted to avoid leaks.
	public func notificationsProducerForName(name: String, object: AnyObject? = nil) -> SignalProducer<NSNotification, NoError> {
		return SignalProducer { observer, disposable in
			let notificationObserver = self.addObserverForName(name, object: object, queue: nil) { notification in
				observer.sendNext(notification)
			}

			disposable.addDisposable {
				self.removeObserver(notificationObserver)
			}
		}
	}
}

// ----------------------------------------------------------------------------
// MARK: - Executors

extension NSNotificationCenter {
	/// Returns an Exector that executes an Action whenever a notification named
	/// `name` is sent.
	public func executorForName(name: String, object: AnyObject? = nil) -> Executor<NSNotification> {
		return Executor(trigger: notificationsProducerForName(name, object: object))
	}
}
