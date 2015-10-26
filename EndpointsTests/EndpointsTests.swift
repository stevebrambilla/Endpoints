//
//  EndpointsTests.swift
//  EndpointsTests
//
//  Created by Steve Brambilla on 2015-06-10.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit
import XCTest
import Endpoints
import ReactiveCocoa

class EndpointsTests: XCTestCase {
	var disposable: CompositeDisposable!

	override func setUp() {
		disposable = CompositeDisposable()
	}

	override func tearDown() {
		disposable.dispose()
	}

    func testBindingWithMethod() {
		let producer = SignalProducer<String, NoError>(value: "Bound!")
		let target = EndpointTarget()
		disposable += target.textEndpoint.bind(producer)
		XCTAssert(target.text == "Bound!")
    }

	func testBindingWithOperator() {
		let target = EndpointTarget()
		disposable += target.textEndpoint <~ SignalProducer<String, NoError>(value: "Bound!")
		XCTAssert(target.text == "Bound!")
	}

	func testDisposing() {
		let (producer, observer) = SignalProducer<String, NoError>.buffer()

		let target = EndpointTarget()
		let textDisposable = target.textEndpoint <~ producer
		XCTAssert(target.text == "")

		sendNext(observer, "first")
		XCTAssert(target.text == "first")

		textDisposable.dispose()

		sendNext(observer, "second")
		XCTAssert(target.text == "first")
	}

	func testDisposesOnZeroedTarget() {
		let addedDisposable = SimpleDisposable()
		var sink: Signal<String, NoError>.Observer!

		let producer = SignalProducer<String, NoError>() { observer, disposable in
			disposable.addDisposable(addedDisposable)
			sink = observer
		}

		var target: EndpointTarget? = EndpointTarget()
		target!.textEndpoint <~ producer
		XCTAssert(target!.text == "")

		sendNext(sink, "first")
		XCTAssert(target!.text == "first")

		target = nil
		XCTAssert(addedDisposable.disposed == false)

		sendNext(sink, "second")
		XCTAssert(addedDisposable.disposed == true, "Expected short circuit after sending second value")
	}

	func testOnCallbacks() {
		let target = EndpointTarget()

		var beforeValue: String?
		var afterValue: String?

		let textProducer = SignalProducer<String, NoError>(value: "Bound!")
		disposable += target.textEndpoint
			.on(before: { value in beforeValue = value }, after: { value in afterValue = value })
			.bind(textProducer)

		XCTAssert(target.text == "Bound!")
		XCTAssert(beforeValue == "Bound!")
		XCTAssert(afterValue == "Bound!")
	}
}
