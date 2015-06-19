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

	internal init(callback: AnyObject -> ()) {
		self.callback = callback
	}

	internal var selector: Selector {
		return "invoke:"
	}

	@objc
	private func invoke(sender: AnyObject) {
		callback(sender)
	}
}
