//
//  UIButton+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-14.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit
import ReactiveCocoa

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UIButton {
	/// An `Endpoint` to bind a `SignalProducer` to the `UIButton`'s title 
	/// label's `font` value.
	public var titleFontEndpoint: Endpoint<UIFont> {
		return Endpoint(self) { $0.titleLabel?.font = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIButton`'s title
	/// label's `textColor` value.
	public var titleColorEndpoint: Endpoint<UIColor> {
		return Endpoint(self) { $0.titleLabel?.textColor = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIButton`'s `title`
	/// value for the Normal control state.
	public var titleEndpoint: Endpoint<String> {
		return Endpoint(self) { $0.setTitle($1, forState: .Normal) }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIButton`'s
	/// `attributedTitle` value for the Normal control state.
	public var attributedTitleEndpoint: Endpoint<NSAttributedString> {
		return Endpoint(self) { $0.setAttributedTitle($1, forState: .Normal) }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIButton`'s `image` 
	/// value for the Normal control state.
	public var imageEndpoint: Endpoint<UIImage> {
		return Endpoint(self) { $0.setImage($1, forState: .Normal) }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIButton`'s
	/// `backgroundImage` value for the Normal control state.
	public var backgroundImageEndpoint: Endpoint<UIImage> {
		return Endpoint(self) { $0.setBackgroundImage($1, forState: .Normal) }
	}
}

// ----------------------------------------------------------------------------
// MARK: - Signal Producer

extension UIButton {
	/// Returns a signal producer that sends the `sender` each time an action
	/// message is sent for a .TouchUpInside event on the `UIButton`
	///
	/// Note that the `UIButton` is weakly referenced by the `SignalProducer`.
	/// If the `UIButton` is deallocated before the signal producer is started
	/// it will complete immediately. Otherwise this producer will not terminate
	/// naturally, so it must be explicitly disposed to avoid leaks.
	public func buttonTapProducer() -> SignalProducer<AnyObject, NoError> {
		return controlEventsProducer(UIControlEvents.TouchUpInside)
	}
}