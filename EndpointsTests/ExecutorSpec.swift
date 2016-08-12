//
//  ExecutorSpec.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2016-08-12.
//  Copyright © 2016 Steve Brambilla. All rights reserved.
//

import Foundation
import Endpoints
import ReactiveCocoa
import Result
import Quick
import Nimble

class ExecutorSpec: QuickSpec {
	override func spec() {
		var disposable: CompositeDisposable!

		beforeEach { disposable = CompositeDisposable() }
		afterEach { disposable.dispose() }

		describe("Executing") {
			it("should bind using bindTo method") {
				let source = ExecutorSource()

				let action = Action<Int, Int, NoError> { x in
					return SignalProducer(value: x)
				}

				var count = 0
				action.values.observeNext { _ in count += 1 }

				disposable += source.executor.bindTo(action)
				expect(count) == 0

				source.trigger()
				expect(count) == 1

				source.trigger()
				expect(count) == 2
			}


			it("should bind with transformation") {
				let source = ExecutorSource()

				let action = Action<String, String, NoError> { x in
					return SignalProducer(value: x)
				}

				var last = "--"
				action.values.observeNext { last = $0 }

				disposable += source.executor.bindTo(action) { x in String(x) }
				expect(last) == "--"

				source.trigger()
				expect(last) == "0"
			}

			it("should bind using operator") {
				let source = ExecutorSource()

				let action = Action<Int, Int, NoError> { x in
					return SignalProducer(value: x)
				}

				var count = 0
				action.values.observeNext { _ in count += 1 }

				disposable += source.executor.bindTo(action)
				expect(count) == 0

				source.trigger()
				expect(count) == 1

				source.trigger()
				expect(count) == 2
			}
		}

		describe("Enabled") {
			it("should bind the enabled value") {
				let source = ExecutorSource()

				let (signal, observer) = Signal<Int, NoError>.pipe()
				let action = Action<Int, Int, NoError> { _ in
					return SignalProducer(signal: signal)
				}

				disposable += source.executor.bindTo(action)
				expect(source.enabled) == true

				source.trigger()
				expect(source.enabled).toEventually(beFalse())

				observer.sendCompleted()
				expect(source.enabled).toEventually(beTrue())
			}
		}

		describe("Callback") {
			it("should execute the 'on' callback") {
				let source = ExecutorSource()

				let (signal, observer) = Signal<Int, NoError>.pipe()
				let action = Action<Int, Int, NoError> { _ in
					return SignalProducer(signal: signal)
				}

				var onEnabled: Bool?

				disposable += source.executor
					.on(enabled: { enabled in onEnabled = enabled })
					.bindTo(action)

				expect(source.enabled) == true
				expect(onEnabled) == true

				source.trigger()
				expect(source.enabled).toEventually(beFalse())
				expect(onEnabled) == false

				observer.sendCompleted()
				expect(source.enabled).toEventually(beTrue())
				expect(onEnabled) == true
			}
		}

		describe("Disposal") {
			it("should dispose of binding") {
				let source = ExecutorSource()

				let action = Action<Int, Int, NoError> { x in
					return SignalProducer(value: x)
				}

				var count = 0
				action.values.observeNext { _ in count += 1 }

				let actionDisposable = source.executor.bindTo(action)
				expect(count) == 0

				source.trigger()
				expect(count) == 1

				actionDisposable.dispose()

				source.trigger()
				expect(count) == 1
			}
		}

		describe("Input Adapter") {
			it("should ignore payload") {
				let source = ExecutorSource()

				let action = Action<(), String, NoError> { x in
					return SignalProducer(value: "Done")
				}

				var last = "--"
				action.values.observeNext { last = $0 }

				disposable += source.executor
					.ignorePayloads()
					.bindTo(action)
				expect(last) == "--"

				source.trigger()
				expect(last) == "Done"
			}

			it("should transform payload") {
				let source = ExecutorSource()

				let action = Action<String, String, NoError> { x in
					return SignalProducer(value: x)
				}

				var last = "--"
				action.values.observeNext { last = $0 }

				disposable += source.executor
					.mapPayloads { String($0) }
					.bindTo(action)
				expect(last) == "--"

				source.trigger()
				expect(last) == "0"
			}
		}
	}
}
