//
//  NSNotificationCenter+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-11-22.
//  Copyright © 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

// ----------------------------------------------------------------------------
// MARK: - Signal Producers

extension NotificationCenter {
	/// Returns a signal producer that sends notifications each time the 
	/// notification sender sends a notification named `name` from the object 
	/// `object`, if one is provided.
	///
	/// Note that the `NotificationCenter` is strongly referenced by the
	/// `SignalProducer`. This producer will not terminate naturally, so it must
	/// be disposed of or interrupted to avoid leaks.
	public func notificationsProducer(forName name: Notification.Name, object: AnyObject? = nil) -> SignalProducer<Notification, NoError> {
		return SignalProducer { observer, disposable in
			let notificationObserver = self.addObserver(forName: name, object: object, queue: nil) { notification in
				observer.send(value: notification)
			}

			disposable.add {
				self.removeObserver(notificationObserver)
			}
		}
	}
}

// ----------------------------------------------------------------------------
// MARK: - Executors

extension NotificationCenter {
	/// Returns an Exector that executes an Action whenever a notification named
	/// `name` is sent.
	public func executor(forName name: Notification.Name, object: AnyObject? = nil) -> Executor<Notification> {
		return Executor(trigger: notificationsProducer(forName: name, object: object))
	}
}
