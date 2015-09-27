//
//  UIBarButtonItem+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-19.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveCocoa

// ----------------------------------------------------------------------------
// MARK: - Signal Producer

extension UIBarButtonItem {
	/// Returns a signal producer that sends the `sender` each time an action
	/// message is sent.
	///
	/// Note that the UIBarButtonItem is weakly referenced by the
	/// SignalProducer. If the UIBarButtonItem is deallocated before the signal
	/// producer is started it will complete immediately. Otherwise this
	/// producer will not terminate naturally, so it must be explicitly disposed 
	/// to avoid leaks.
	///
	/// This will reset the item's `target` and `action`.
	public func buttonTapProducer() -> SignalProducer<AnyObject, NoError> {
		return SignalProducer() { [weak self] observer, disposable in
			let target = ObjCTarget() { sender in
				sendNext(observer, sender)
			}

			if let buttonItem = self {
				buttonItem.target = target
				buttonItem.action = target.selector

				disposable.addDisposable {
					target.dispose() // Strongly retain `target`
					self?.target = nil
					self?.action = nil
				}
			} else {
				sendCompleted(observer)
			}
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
	public var executor: Executor<AnyObject> {
		return Executor(enabled: enabledEndpoint, trigger: buttonTapProducer())
	}
}
