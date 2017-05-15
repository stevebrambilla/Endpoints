//
//  ObjCTarget.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-13.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation

internal class ObjCTarget: NSObject {
	private let callback: (AnyObject) -> Void
	private var disposed = false

	internal init(callback: @escaping (AnyObject) -> Void) {
		self.callback = callback
	}

	internal var selector: Selector {
		return #selector(ObjCTarget.invoke(_:))
	}

	internal func dispose() {
		disposed = true
	}

	@objc private func invoke(_ sender: AnyObject) {
		if !disposed {
			callback(sender)
		}
	}
}
