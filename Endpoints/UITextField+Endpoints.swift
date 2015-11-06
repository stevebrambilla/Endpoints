//
//  UITextField+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-14.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit
import ReactiveCocoa

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UITextField {
	/// An `Endpoint` to bind a `SignalProducer` to the `UITextField`'s `text`
	/// value.
	public var textEndpoint: Endpoint<String> {
		return Endpoint(self) { $0.text = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UITextField`'s
	/// `attributedText` value.
	public var attributedTextEndpoint: Endpoint<NSAttributedString> {
		return Endpoint(self) { $0.attributedText = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UITextField`'s `font`
	/// value.
	public var fontEndpoint: Endpoint<UIFont> {
		return Endpoint(self) { $0.font = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UITextField`'s
	/// `textColor` value.
	public var textColorEndpoint: Endpoint<UIColor> {
		return Endpoint(self) { $0.textColor = $1 }
	}
}

// ----------------------------------------------------------------------------
// MARK: - Signal Producers

extension UITextField {
	/// Returns a signal producer that sends the `text` value each time it is
	/// changed.
	///
	/// Note that the `UITextField` is strongly referenced by the
	/// `SignalProducer`. This producer will not terminate naturally, so it must
	/// be disposed or interrupted to avoid leaks.
	///
	/// The current value of `text` is sent immediately upon starting the signal
	/// producer.
	public var textProducer: SignalProducer<String?, NoError> {
		// Current value lookup deferred until producer is started.
		let currentValue = SignalProducer<String?, NoError> { observer, _ in
			observer.sendNext(self.text)
			observer.sendCompleted()
		}

		let textChanges = controlEventsProducer(UIControlEvents.AllEditingEvents)
			.map { sender -> String? in
				guard let textField = sender as? UITextField else {
					fatalError("Expected sender to be an instance of UITextField, got: \(sender).")
				}
				return textField.text
			}

		return currentValue.concat(textChanges)
	}

	/// Returns a signal producer that sends the `editing` value each time an
	/// editing event is sent.
	///
	/// Note that the `UITextField` is strongly referenced by the
	/// `SignalProducer`. This producer will not terminate naturally, so it must
	/// be disposed or interrupted to avoid leaks.
	///
	/// The current value of `editing` is sent immediately upon starting the
	/// signal producer.
	public var editingProducer: SignalProducer<Bool, NoError> {
		// Current value lookup deferred until producer is started.
		let currentValue = SignalProducer<Bool, NoError> { observer, _ in
			observer.sendNext(self.editing)
			observer.sendCompleted()
		}

		let editingChanges = controlEventsProducer(UIControlEvents.AllEditingEvents)
			.map { sender -> Bool in
				if let textField = sender as? UITextField {
					return textField.editing
				} else {
					fatalError("Expected sender to be an instance of UITextField, got: \(sender).")
				}
			}

		return currentValue.concat(editingChanges)
	}
}
