//
//  ObjCTarget.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-13.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation

internal class ObjCTarget: NSObject {
	fileprivate let callback: (AnyObject) -> ()
	fileprivate var disposed = false

	internal init(callback: @escaping (AnyObject) -> ()) {
		self.callback = callback
	}

	internal var selector: Selector {
		return #selector(ObjCTarget.invoke(_:))
	}

	internal func dispose() {
		disposed = true
	}

	@objc fileprivate func invoke(_ sender: AnyObject) {
		if !disposed {
			callback(sender)
		}
	}
}
