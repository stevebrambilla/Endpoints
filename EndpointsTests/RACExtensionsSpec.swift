//
//  RACExtensionsSpec.swift
//  Endpoints
//
//  Created by Steve Brambilla on 2015-06-20.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Endpoints
import ReactiveSwift
import Result
import Quick
import Nimble

class RACExtensionsSpec: QuickSpec {
	override func spec() {
		describe("animateFollowingFirst") {
			it("should map to tuples with the first value being false") {
				let source = SignalProducer<Int, NoError>([1, 2, 3])
				let producer = source.animateFollowingFirst()

				let result = producer.collect().last()

				guard let tuples = result?.value else { return fail() }

				expect(tuples.count) == 3

				let firstPasses = (tuples[0] == (1, false))
				expect(firstPasses) == true

				let secondPasses = (tuples[1] == (2, true))
				expect(secondPasses) == true

				let thirdPasses = (tuples[2] == (3, true))
				expect(thirdPasses) == true
			}
		}

		describe("withInitialValue") {
			it("should map to tuples with the first value being false") {
				let (signal, observer) = Signal<Int, NoError>.pipe()

				var tested = false
				signal
					.withInitialValue(1)
					.collect()
					.startWithValues { values in
						expect(values[0]) == 1
						expect(values[1]) == 2
						expect(values[2]) == 3
						tested = true
					}

				observer.send(value: 2)
				observer.send(value: 3)
				observer.sendCompleted()
				
				expect(tested) == true
			}
		}
	}
}
