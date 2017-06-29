//
//  EndpointSpec.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2016-08-12.
//  Copyright © 2016 Steve Brambilla. All rights reserved.
//

import Foundation
import Endpoints
import ReactiveSwift
import Result
import Quick
import Nimble

class EndpointSpec: QuickSpec {
	override func spec() {
		var disposable: CompositeDisposable!

		beforeEach { disposable = CompositeDisposable() }
		afterEach { disposable.dispose() }

		describe("Binding") {
			it("should bind using bind method") {
				let producer = SignalProducer<String, NoError>(value: "Bound!")
				let target = EndpointTarget()
				disposable += target.textEndpoint.bind(from: producer)
				expect(target.text) == "Bound!"
			}

			it("should bind using operator") {
				let target = EndpointTarget()
				disposable += target.textEndpoint <~ SignalProducer<String, NoError>(value: "Bound!")
				expect(target.text) == "Bound!"
			}
		}

		describe("Disposing") {
			it("should dispose when disposable is disposed") {
				let property = MutableProperty<String>("")

				let target = EndpointTarget()
				let textDisposable = target.textEndpoint.bind(from: property.producer)
				expect(target.text) == ""

				property.value = "first"
				expect(target.text) == "first"

				textDisposable.dispose()

				property.value = "second"
				expect(target.text) == "first"
			}

			it("should dispose when target is zeroed out") {
				let addedDisposable = AnyDisposable()
				var signalObserver: Signal<String, NoError>.Observer!

				let producer = SignalProducer<String, NoError>() { observer, disposable in
					disposable.observeEnded { addedDisposable.dispose() }
					signalObserver = observer
				}

				var target: EndpointTarget? = EndpointTarget()
				target!.textEndpoint.bind(from: producer)
				expect(target!.text) == ""

				signalObserver.send(value: "first")
				expect(target!.text) == "first"

				target = nil
				expect(addedDisposable.isDisposed) == false

				// Should short circuit after sending second value
				signalObserver.send(value: "second")
				expect(addedDisposable.isDisposed) == true
			}
		}

		describe("Callback") {
			it("should execute the 'on' callback") {
				let target = EndpointTarget()

				var beforeValue: String?
				var afterValue: String?

				let textProducer = SignalProducer<String, NoError>(value: "Bound!")
				disposable += target.textEndpoint
					.on(before: { value in beforeValue = value }, after: { value in afterValue = value })
					.bind(from: textProducer)

				expect(target.text) == "Bound!"
				expect(beforeValue) == "Bound!"
				expect(afterValue) == "Bound!"
			}
		}
	}
}
