//
//  RACExtensionTests.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-20.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit
import XCTest
import ReactiveCocoa
import Endpoints
import Result

class RACExtensionTests: XCTestCase {
	func testAnimateFollowingFirst() {
		let source = SignalProducer<Int, NoError>(values: [1, 2, 3])
		let producer = source.animateFollowingFirst()

		let result = producer.collect().last()

		if let tuples = result?.value where tuples.count == 3 {
			XCTAssert(tuples[0].0 == 1 && tuples[0].1 == false)
			XCTAssert(tuples[1].0 == 2 && tuples[1].1 == true)
			XCTAssert(tuples[2].0 == 3 && tuples[2].1 == true)
		} else {
			XCTAssert(false)
		}
	}

	func testWithInitialValue() {
		let (signal, observer) = Signal<Int, NoError>.pipe()

		var tested = false
		signal
			.withInitialValue(1)
			.collect()
			.startWithNext { values in
				XCTAssert(values[0] == 1)
				XCTAssert(values[1] == 2)
				XCTAssert(values[2] == 3)
				tested = true
			}

		sendNext(observer, 2)
		sendNext(observer, 3)
		sendCompleted(observer)

		XCTAssert(tested)
	}
}
