//
//  UIView+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-13.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UIView {
	/// An `Endpoint` to bind a `SignalProducer` to the `UIView`'s 
	/// `userInteractionEnabled` value.
	public var userInteractionEnabledEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.userInteractionEnabled = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIView`'s 
	/// `backgroundColor` value.
	public var backgroundColorEndpoint: Endpoint<UIColor> {
		return Endpoint(self) { $0.backgroundColor = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIView`'s `hidden` 
	/// value.
	public var hiddenEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.hidden = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIView`'s `alpha` 
	/// value.
	public var alphaEndpoint: Endpoint<CGFloat> {
		return Endpoint(self) { $0.alpha = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIView`'s `tintColor` 
	/// value.
	public var tintColorEndpoint: Endpoint<UIColor> {
		return Endpoint(self) { $0.tintColor = $1 }
	}
}
