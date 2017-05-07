//
//  AppUrls.swift
//  ArhaticYogaJournaliOS
//
//  Created by Eduardo Sztokbant on 5/6/17.
//  Copyright © 2017 Eduardo Sztokbant. All rights reserved.
//

class AppUrls {
    let allowedDomains: Array<String> = ["arhaticnet.herokuapp.com",
                                         "ayj-beta.herokuapp.com",
                                         "ayjournal.herokuapp.com",
                                         "arhaticyogajournal.com"]

    let signedOutUrlPatterns: Array<String> = ["/welcome", "/password_reset", "/users/pwext"]

    let defaultDomain: String = "arhaticnet.herokuapp.com"
    var currentDomain: String = ""

    func isAllowed(url: String) -> Bool {
        return allowedDomains.contains(url)
    }

    func isSignedOut(url: String) -> Bool {
        for (_, element) in signedOutUrlPatterns.enumerated() {
            if (url.contains(element)) {
                return true
            }
        }
        return false
    }
}
