//
//  AppUrls.swift
//  ArhaticYogaJournaliOS
//
//  Created by Eduardo Sztokbant on 5/6/17.
//  Copyright © 2017 Eduardo Sztokbant. All rights reserved.
//
import UIKit

class AppUrls {
    private let CURRENT_DOMAIN_KEY: String = "currentDomain"

    private let GENERIC_DOMAIN_PREFIX: String = "ayj"
    private let GENERIC_DOMAIN_SUFFIX: String = ".herokuapp.com"

    private let allowedDomains: Array<String> = ["arhaticnet.herokuapp.com",
                                                 "arhaticyogajournal.com"]
    private var currentDomain: String = ""

    private let signedOutUrlPatterns: Array<String> = ["/about?s=0", "/password_reset", "/users/pwext", "/welcome"]

    init() {
        let currentDomainOpt: String? = UserDefaults.standard.string(forKey: CURRENT_DOMAIN_KEY)
        self.setCurrentDomain(currentDomain: currentDomainOpt ?? "arhaticnet.herokuapp.com")
    }

    func getCurrentDomain() -> String {
        return currentDomain
    }

    func setCurrentDomain(currentDomain: String) {
        self.currentDomain = currentDomain
        UserDefaults.standard.set(currentDomain, forKey: CURRENT_DOMAIN_KEY)
    }

    func getCurrentUrl() -> String {
        return "https://" + currentDomain
    }

    func isAllowed(domain: String) -> Bool {
        return allowedDomains.contains(domain) || isAllowedGeneric(domain: domain)
    }

    private func isAllowedGeneric(domain: String) -> Bool {
        return domain.hasPrefix(GENERIC_DOMAIN_PREFIX) &&
            domain.hasSuffix(GENERIC_DOMAIN_SUFFIX) &&
            domain.count > GENERIC_DOMAIN_PREFIX.count + GENERIC_DOMAIN_SUFFIX.count
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
