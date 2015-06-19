//
//  EndpointTarget.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-17.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import Endpoints

class EndpointTarget: NSObject {
	var text: String = ""
	var number: Int = 0
}

extension EndpointTarget {
	var textEndpoint: Endpoint<String> {
		return Endpoint(self) { $0.text = $1 }
	}

	var numberEndpoint: Endpoint<Int> {
		return Endpoint(self) { $0.number = $1 }
	}
}
