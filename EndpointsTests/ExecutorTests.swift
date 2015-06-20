//
//  ExecutorTests.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-19.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import XCTest
import Endpoints
import ReactiveCocoa

class ExecutorTests: XCTestCase {
	func testDirectBindingWithMethod() {
		let source = ExecutorSource()

		let action = Action<Int, Int, NoError> { x in
			return SignalProducer(value: x)
		}

		var count = 0
		action.values.observe(next: { _ in count++ })

		source.executor.bind(action)
		XCTAssert(count == 0)

		source.trigger()
		XCTAssert(count == 1)

		source.trigger()
		XCTAssert(count == 2)
	}

	func testTransformedBindingWithMethod() {
		let source = ExecutorSource()

		let action = Action<String, String, NoError> { x in
			return SignalProducer(value: x)
		}

		var last = "--"
		action.values.observe(next: { last = $0 })

		source.executor.bind(action) { x in "\(x)" }
		XCTAssert(last == "--")

		source.trigger()
		XCTAssert(last == "0")
	}

	func testDirectBindingWithOperator() {
		let source = ExecutorSource()

		let action = Action<Int, Int, NoError> { x in
			return SignalProducer(value: x)
		}

		var count = 0
		action.values.observe(next: { _ in count++ })

		source.executor <~ action
		XCTAssert(count == 0)

		source.trigger()
		XCTAssert(count == 1)

		source.trigger()
		XCTAssert(count == 2)
	}

	func testEnabledBinding() {
		let source = ExecutorSource()

		let (producer, observer) = SignalProducer<Int, NoError>.buffer(1)
		let action = Action<Int, Int, NoError> { x in
			return producer
		}

		source.executor <~ action
		XCTAssert(source.enabled == true)

		source.trigger()
		XCTAssert(source.enabled == false)

		sendCompleted(observer)
		XCTAssert(source.enabled == true)
	}

	func testDisposing() {
		let source = ExecutorSource()

		let action = Action<Int, Int, NoError> { x in
			return SignalProducer(value: x)
		}

		var count = 0
		action.values.observe(next: { _ in count++ })

		let disposable = source.executor <~ action
		XCTAssert(count == 0)

		source.trigger()
		XCTAssert(count == 1)

		disposable.dispose()

		source.trigger()
		XCTAssert(count == 1)
	}
}
