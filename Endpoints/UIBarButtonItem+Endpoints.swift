//
//  UIBarButtonItem+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-19.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

// ----------------------------------------------------------------------------
// MARK: - Signal Producer

extension UIBarButtonItem {
	/// Returns a signal producer that sends the `sender` each time an action
	/// message is sent.
	///
	/// Note that the `UIBarButtonItem` is strongly referenced by the
	/// `SignalProducer`. This producer will not terminate naturally, so it must
	/// be disposed or interrupted to avoid leaks.
	///
	/// This will reset the item's `target` and `action`.
	public var triggerProducer: SignalProducer<UIBarButtonItem, NoError> {
		let sourceEvents = SignalProducer<AnyObject, NoError> { observer, disposable in
			let target = ObjCTarget() { sender in
				observer.send(value: sender)
			}

			self.target = target
			self.action = target.selector

			disposable.add {
				target.dispose() // Strongly retains `target`
				self.target = nil
				self.action = nil
			}
		}

		return sourceEvents.map { sender in
			guard let item = sender as? UIBarButtonItem else {
				fatalError("Expected sender to be an instance of UIBarButtonItem, got: \(sender).")
			}
			return item
		}
	}
}

// ----------------------------------------------------------------------------
// MARK: - Executor

extension UIBarButtonItem {
	/// Returns an Exector that executes an Action when the UIBarButtonItem is
	/// tapped, and binds its `enabled` value to the Action's.
	///
	/// This will reset the item's `target` and `action`.
	public var executor: Executor<UIBarButtonItem> {
		return Executor(enabled: enabledEndpoint, trigger: triggerProducer)
	}
}
