//
//  UIProgressView+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-14.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UIProgressView {
	/// An `Endpoint` to bind a `SignalProducer` to the `UIProgressView`'s
	/// `progress` value, optionally with animation. The `Endpoint` accepts
	/// a tuple where the Float is the progress, and the Bool determines whether
	/// the change is animated.
	public var animatedProgressEndpoint: Endpoint<(Float, Bool)> {
		return Endpoint(self) { view, tuple in view.setProgress(tuple.0, animated: tuple.1) }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIProgressView`'s 
	/// `progress` value without animation.
	public var progressEndpoint: Endpoint<Float> {
		return Endpoint(self) { $0.progress = $1 }
	}
}
