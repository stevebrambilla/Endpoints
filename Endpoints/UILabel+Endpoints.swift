//
//  UILabel+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-13.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UILabel {
	/// An `Endpoint` to bind a `SignalProducer` to the `UILabel`'s `text`
	/// value.
	public var textEndpoint: Endpoint<String?> {
		return Endpoint(self) { $0.text = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UILabel`'s
	/// `attributedText` value.
	public var attributedTextEndpoint: Endpoint<NSAttributedString?> {
		return Endpoint(self) { $0.attributedText = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UILabel`'s `font`
	/// value.
	public var fontEndpoint: Endpoint<UIFont> {
		return Endpoint(self) { $0.font = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UILabel`'s `textColor`
	/// value.
	public var textColorEndpoint: Endpoint<UIColor> {
		return Endpoint(self) { $0.textColor = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UILabel`'s `enabled`
	/// value.
	public var enabledEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.isEnabled = $1 }
	}
}
