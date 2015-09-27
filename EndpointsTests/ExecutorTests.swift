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
	var disposable: CompositeDisposable!

	override func setUp() {
		disposable = CompositeDisposable()
	}

	override func tearDown() {
		disposable.dispose()
	}

	func testDirectBindingWithMethod() {
		let source = ExecutorSource()

		let action = Action<Int, Int, NoError> { x in
			return SignalProducer(value: x)
		}

		var count = 0
		action.values.observeNext { _ in count++ }

		disposable += source.executor.bind(action)
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
		action.values.observeNext { last = $0 }

		disposable += source.executor.bind(action) { x in String(x) }
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
		action.values.observeNext { _ in count++ }

		disposable += source.executor.bind(action)
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

		disposable += source.executor.bind(action)
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
		action.values.observeNext { _ in count++ }

		let actionDisposable = source.executor.bind(action)
		XCTAssert(count == 0)

		source.trigger()
		XCTAssert(count == 1)

		actionDisposable.dispose()

		source.trigger()
		XCTAssert(count == 1)
	}

	func testIgnoringInputAdaptor() {
		let source = ExecutorSource()

		let action = Action<(), String, NoError> { x in
			return SignalProducer(value: "Done")
		}

		var last = "--"
		action.values.observeNext { last = $0 }

		disposable += source.executor
			.ignorePayloads()
			.bind(action)
		XCTAssert(last == "--")

		source.trigger()
		XCTAssert(last == "Done")
	}

	func testTransformingInputAdaptor() {
		let source = ExecutorSource()

		let action = Action<String, String, NoError> { x in
			return SignalProducer(value: x)
		}

		var last = "--"
		action.values.observeNext { last = $0 }

		disposable += source.executor
			.mapPayloads { String($0) }
			.bind(action)
		XCTAssert(last == "--")

		source.trigger()
		XCTAssert(last == "0")
	}
}
