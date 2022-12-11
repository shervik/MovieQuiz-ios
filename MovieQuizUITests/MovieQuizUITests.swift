//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Виктория Щербакова on 01.12.2022.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }

    func testYesButton() throws {
        let firstPoster = app.images["Poster"]
        app.buttons["Yes"].tap()
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        sleep(3)
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testNoButton() throws {
        let firstPoster = app.images["Poster"]
        app.buttons["No"].tap()
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        sleep(3)
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testShowAlert() {
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1)
        }
        sleep(3)
        let alert = app.alerts["Alert"]
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.label == "10/10")
        XCTAssertTrue(app.alerts["Alert"].exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
    }

    func testRerunGame() {
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1)
        }
        sleep(3)
        let alert = app.alerts["Alert"]
        XCTAssertTrue(app.alerts["Alert"].exists)
        alert.buttons.firstMatch.tap()
        sleep(1)
        XCTAssertFalse(app.alerts["Alert"].exists)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
