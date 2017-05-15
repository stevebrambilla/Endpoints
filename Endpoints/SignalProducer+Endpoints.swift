//
//  SignalProducer+Endpoints.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-14.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import ReactiveSwift

extension SignalProducerProtocol {
	/// Maps the producer into a producer of tuples, with a `following` flag as the
	/// second parameter of the tuple. The `following` value is set to false for the
	/// first Next event, then true for all following Next events.
	///
	/// This can be used in conjunction with Endpoints that accept a tuple with an
	/// animated flag as the second parameter to avoid animating initial values.
	public func animateFollowingFirst() -> SignalProducer<(Value, Bool), Error> {
		var first = true
		return producer.map { value in
			let tuple = (value, !first)
			first = false
			return tuple
		}
	}
}
