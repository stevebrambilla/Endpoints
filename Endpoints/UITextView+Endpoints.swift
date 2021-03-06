//
//  UITextView+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-14.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

// ----------------------------------------------------------------------------
// MARK: - Endpoints

// Endpoints that are available for iOS, but not for tvOS.
#if os(iOS)
extension UITextView {
	/// An `Endpoint` to bind a `SignalProducer` to the `UITextView`'s
	/// `editable` value.
	public var editableEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.isEditable = $1 }
	}
}
#endif

extension UITextView {
	/// An `Endpoint` to bind a `SignalProducer` to the `UITextView`'s `text`
	/// value.
	public var textEndpoint: Endpoint<String?> {
		return Endpoint(self) { $0.text = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UITextView`'s
	/// `attributedText` value.
	public var attributedTextEndpoint: Endpoint<NSAttributedString?> {
		return Endpoint(self) { $0.attributedText = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UITextView`'s `font`
	/// value.
	public var fontEndpoint: Endpoint<UIFont> {
		return Endpoint(self) { $0.font = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UITextView`'s
	/// `textColor` value.
	public var textColorEndpoint: Endpoint<UIColor> {
		return Endpoint(self) { $0.textColor = $1 }
	}
}

// ----------------------------------------------------------------------------
// MARK: - Signal Producers

extension UITextView {
	/// Returns a signal producer that sends the `text` value each time it is
	/// changed.
	///
	/// Note that the `UITextView` is strongly referenced by the
	/// `SignalProducer`. This producer will not terminate naturally, so it must
	/// be disposed or interrupted to avoid leaks.
	///
	/// The current value of `text` is sent immediately upon starting the signal
	/// producer.
	public var textProducer: SignalProducer<String, NoError> {
		// Current value lookup deferred until producer is started.
		let currentValue = SignalProducer<String, NoError> { observer, _ in
			observer.send(value: self.text)
			observer.sendCompleted()
		}

		let textChanges = NotificationCenter.default.notificationsProducer(forName: Notification.Name.UITextViewTextDidChange)
			.map { notification -> String in
				if let textView = notification.object as? UITextView {
					return String(textView.text)
				} else {
					fatalError("Expected notification object to be UITextView")
				}
			}

		return currentValue.concat(textChanges)
	}

	/// Returns a signal producer that sends the `editing` value each time the
	/// editing state of is changed.
	///
	/// Note that the `UITextView` is weakly referenced by the `SignalProducer`.
	/// If the `UITextView` is deallocated before the signal producer is started
	/// it will complete immediately. Otherwise this producer will not terminate
	/// naturally, so it must be explicitly disposed to avoid leaks.
	///
	/// The current editing state cannot be determined from this scope,
	/// therefore the function accepts an optional `initialValue` the will be
	/// sent immediately upon starting the signal. If not `initialValue` is 
	/// provided it defaults to `false`.
	public func editingProducer(_ initialValue: Bool = false) -> SignalProducer<Bool, NoError> {
		let beganEditing = NotificationCenter.default.notificationsProducer(forName: Notification.Name.UITextViewTextDidBeginEditing, object: self).map { _ in true }
		let endedEditing = NotificationCenter.default.notificationsProducer(forName: Notification.Name.UITextViewTextDidEndEditing, object: self).map { _ in false }
		let editingChanges = SignalProducer.merge(beganEditing, endedEditing)
		return SignalProducer(value: initialValue).concat(editingChanges)
	}
}
