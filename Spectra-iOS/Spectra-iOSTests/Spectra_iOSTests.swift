//
//  Spectra_iOSTests.swift
//  Spectra-iOSTests
//
//  Created by David Conner on 11/28/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

@testable import SpectraiOS
import Quick
import Nimble

class SpectraOSXTests: QuickSpec {
    override func spec() {
        expect(Spectra.foo()).to(beTrue())
    }
}
