//
//  UIBarItem+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-14.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UIBarItem {
	/// An `Endpoint` to bind a `SignalProducer` to the `UIBarItem`'s `enabled`
	/// value without animation.
	public var enabledEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.isEnabled = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIBarItem`'s `title`
	/// value without animation.
	public var titleEndpoint: Endpoint<String?> {
		return Endpoint(self) { $0.title = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIBarItem`'s `image`
	/// value without animation.
	public var imageEndpoint: Endpoint<UIImage?> {
		return Endpoint(self) { $0.image = $1 }
	}
}
