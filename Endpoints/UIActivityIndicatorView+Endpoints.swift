//
//  UIActivityIndicatorView+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-13.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UIActivityIndicatorView {
	/// An `Endpoint` to bind a `SignalProducer` to the 
	/// `UIActivityIndicatorView`'s animating state. The activity indicator
	/// starts animating when a `true` value is sent, and stops animating when a
	/// `false` value is sent.
	public var animatingEndpoint: Endpoint<Bool> {
		return Endpoint(self) { indicator, animate in
			if animate {
				indicator.startAnimating()
			} else {
				indicator.stopAnimating()
			}
		}
	}

	/// An `Endpoint` to bind a `SignalProducer` to the 
	/// `UIActivityIndicatorView`'s `color` value.
	public var colorEndpoint: Endpoint<UIColor?> {
		return Endpoint(self) { $0.color = $1 }
	}
}
