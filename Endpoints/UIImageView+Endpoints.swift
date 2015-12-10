//
//  UIImageView+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-13.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit

// ----------------------------------------------------------------------------
// MARK: - Endpoints

extension UIImageView {
	/// An `Endpoint` to bind a `SignalProducer` to the `UIImageView`'s `image`
	/// value.
	public var imageEndpoint: Endpoint<UIImage?> {
		return Endpoint(self) { $0.image = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIImageView`'s 
	/// `highlightedImage` value.
	public var highlightedImageEndpoint: Endpoint<UIImage?> {
		return Endpoint(self) { $0.highlightedImage = $1 }
	}

	/// An `Endpoint` to bind a `SignalProducer` to the `UIImageView`'s 
	/// `highlighted` value.
	public var highlightedEndpoint: Endpoint<Bool> {
		return Endpoint(self) { $0.highlighted = $1 }
	}
}