//
//  ArhaticYogaJournaliOSTests.swift
//  ArhaticYogaJournaliOSTests
//
//  Created by Eduardo Sztokbant on 5/5/17.
//  Copyright © 2017 Eduardo Sztokbant. All rights reserved.
//

import XCTest
@testable import ArhaticYogaJournaliOS

class AppUrlsTests: XCTestCase {
    static let CURRENT_DOMAIN_KEY = "currentDomain"

    static let PROD_DOMAIN = "arhaticnet.herokuapp.com"
    static let BETA_DOMAIN = "ayj-beta.herokuapp.com"
    static let GAMMA_DOMAIN = "ayj-gamma.herokuapp.com"
    static let USPHC_DOMAIN = "ayjournal.herokuapp.com"
    static let PUBLIC_DOMAIN = "arhaticyogajournal.com"

    static let PROD_URL = "https://" + PROD_DOMAIN
    static let BETA_URL = "https://" + BETA_DOMAIN
    static let GAMMA_URL = "https://" + GAMMA_DOMAIN
    static let USPHC_URL = "https://" + USPHC_DOMAIN
    static let PUBLIC_URL = "http://" + PUBLIC_DOMAIN

    static let NOT_ALLOWED_URL = "https://www.amazon.com"

    var appUrls: AppUrls!

    override func setUp() {
        super.setUp()
        appUrls = AppUrls()
    }

    override func tearDown() {
        appUrls = nil
        super.tearDown()
    }

    func test_isAllowed_ayjSomething_true() {
        XCTAssertTrue(appUrls.isAllowed(url: "https://ayjsomething.herokuapp.com"))
        XCTAssertTrue(appUrls.isAllowed(url: "https://ayj-something.herokuapp.com"))
    }

    func test_isAllowed_prodUrl_true() {
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.PROD_URL))
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.PROD_URL + "/stats"))
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.PROD_URL + "/welcome"))
    }

    func test_isAllowed_betaUrl_true() {
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.BETA_URL))
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.BETA_URL + "/stats"))
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.BETA_URL + "/welcome"))
    }

    func test_isAllowed_gammaUrl_true() {
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.GAMMA_URL))
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.GAMMA_URL + "/stats"))
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.GAMMA_URL + "/welcome"))
    }

    func test_isAllowed_usphcUrl_true() {
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.USPHC_URL))
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.USPHC_URL + "/stats"))
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.USPHC_URL + "/welcome"))
    }

    func test_isAllowed_publicUrl_true() {
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.PUBLIC_URL))
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.PUBLIC_URL + "/stats"))
        XCTAssertTrue(appUrls.isAllowed(url: AppUrlsTests.PUBLIC_URL + "/welcome"))
    }

    func test_isAllowed_externalUrls_false() {
        XCTAssertFalse(appUrls.isAllowed(url: "http://www.instituteforinnerstudies.com.ph/"))
        XCTAssertFalse(appUrls.isAllowed(url: "https://www.worldpranichealing.com/"))
        XCTAssertFalse(appUrls.isAllowed(url: "http://www.pranichealing.com/course/arhatic-yoga"))
        XCTAssertFalse(appUrls.isAllowed(url: "http://www.globalpranichealing.com/en/courses/8/"))
    }

    func test_isAllowed_somethingAyj_false() {
        XCTAssertFalse(appUrls.isAllowed(url: "https://somethingayj.herokuapp.com"))
        XCTAssertFalse(appUrls.isAllowed(url: "https://something-ayj.herokuapp.com"))
        XCTAssertFalse(appUrls.isAllowed(url: "https://something-ayj-something.herokuapp.com"))
    }

    func test_isAllowed_ayj_false() {
        XCTAssertFalse(appUrls.isAllowed(url: "https://ayj.herokuapp.com"))
    }

    func test_isSignedOut_baseUrlAndStats_false() {
        XCTAssertFalse(appUrls.isSignedOut(url: AppUrlsTests.PROD_URL))
        XCTAssertFalse(appUrls.isSignedOut(url: AppUrlsTests.PROD_URL + "/stats"))
    }

    func test_isSignedOut_welcome_true() {
        XCTAssertTrue(appUrls.isSignedOut(url: AppUrlsTests.PROD_URL + "/welcome"))
        XCTAssertTrue(appUrls.isSignedOut(url: AppUrlsTests.PROD_URL + "/welcome?login_email=user%40example.com"))
    }

    func test_isSignedOut_pwext_true() {
        XCTAssertTrue(
            appUrls.isSignedOut(url:
                AppUrlsTests.PROD_URL
                    + "/users/pwext"
                    + "/1a2b7842207de53103d01fd8b54d7fda4d5bbc52e048532ef8c0fbeadc50edd0"))
    }

    func test_isSignedOutUrl_passwordReset_true() {
        XCTAssertTrue(appUrls.isSignedOut(url: AppUrlsTests.PROD_URL + "/password_reset"))
    }

    func test_setCurrentDomain_betaDomain_updateCurrentDomain() {
        // GIVEN
        appUrls.setCurrentDomain(currentDomain: AppUrlsTests.PROD_DOMAIN)
        XCTAssertEqual(AppUrlsTests.PROD_DOMAIN, appUrls.getCurrentDomain())

        // WHEN
        appUrls.setCurrentDomain(currentDomain: AppUrlsTests.BETA_DOMAIN)

        // THEN
        XCTAssertEqual(AppUrlsTests.BETA_DOMAIN, appUrls.getCurrentDomain())
    }

    func test_isDownloadable_validDomainZipFile_returnTrue() {
        XCTAssertTrue(appUrls.isDownloadable(url: AppUrlsTests.PROD_URL + "/export_data_download.zip"))
    }

    func test_isDownloadable_validDomainHtmlFile_returnFalse() {
        XCTAssertFalse(appUrls.isDownloadable(url: AppUrlsTests.PROD_URL + "/export_data_download.html"))
    }

    func test_isDownloadable_invalidDomainZipFile_returnFalse() {
        XCTAssertFalse(appUrls.isDownloadable(url: AppUrlsTests.NOT_ALLOWED_URL + "/export_data_download.zip"))
    }

    func test_isDownloadable_invalidDomainHtmlFile_returnFalse() {
        XCTAssertFalse(appUrls.isDownloadable(url: AppUrlsTests.NOT_ALLOWED_URL + "/export_data_download.html"))
    }
}
