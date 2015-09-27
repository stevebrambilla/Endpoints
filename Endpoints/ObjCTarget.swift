//
//  ObjCTarget.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-13.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation

internal class ObjCTarget: NSObject {
	private let callback: AnyObject -> ()
	private var disposed = false

	internal init(callback: AnyObject -> ()) {
		self.callback = callback
	}

	internal var selector: Selector {
		return "invoke:"
	}

	internal func dispose() {
		disposed = true
	}

	@objc private func invoke(sender: AnyObject) {
		if !disposed {
			callback(sender)
		}
	}
}
