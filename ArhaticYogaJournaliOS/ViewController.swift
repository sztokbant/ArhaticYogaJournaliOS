//
//  ViewController.swift
//  ArhaticYogaJournaliOS
//
//  Created by Eduardo Sztokbant on 5/5/17.
//  Copyright © 2017 Eduardo Sztokbant. All rights reserved.
//

import UIKit
import Floaty

class ViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate, FloatyDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    var floaty: Floaty = Floaty()

    class var defaultColor: UIColor {
        var cString: String = "7B41A9".trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    let allowedDomains: Array<String> = ["arhaticnet.herokuapp.com",
                                         "ayj-beta.herokuapp.com",
                                         "ayjournal.herokuapp.com",
                                         "arhaticyogajournal.com"]

    let signedOutUrlPatterns: Array<String> = ["/welcome", "/password_reset", "/users/pwext"]

    var currenttUrl: String = "arhaticnet.herokuapp.com"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        buildFloatingActionMenu()
        buildSpinner()
        buildWebView()
    }

    func buildFloatingActionMenu() {
        floaty.addItem(item: buildFloatingActionButton(title: "Log Practice",
                                                       icon: "ic_launcher.png",
                                                       path: "practice_executions/multi"))
        floaty.addItem(item: buildFloatingActionButton(title: "Log Tithing",
                                                       icon: "ic_dollar.png",
                                                       path: "tithings/new"))
        floaty.addItem(item: buildFloatingActionButton(title: "Log Service",
                                                       icon: "ic_service.png",
                                                       path: "services/new"))
        floaty.addItem(item: buildFloatingActionButton(title: "Log Study",
                                                       icon: "ic_study.png",
                                                       path: "studies/new"))

        floaty.plusColor = UIColor.white
        floaty.buttonColor = ViewController.defaultColor

        floaty.animationSpeed = 0.014

        floaty.fabDelegate = self
    }

    func buildFloatingActionButton(title: String, icon: String, path: String) -> FloatyItem {
        let item = FloatyItem()

        item.title = title
        item.icon = UIImage(named: icon)

        item.buttonColor = ViewController.defaultColor
        item.titleColor = UIColor.white
        item.titleShadowColor = ViewController.defaultColor

        item.handler = { item in
            self.webView.loadRequest(URLRequest(url: URL(string: "https://" + self.currenttUrl + "/" + path)!))
        }

        return item
    }

    func buildSpinner() {
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        spinner.color = UIColor.lightGray
    }

    func buildWebView() {
        appendAppInfoToUserAgent()
        webView.delegate = self
        webView.scrollView.delegate = self
        webView.loadRequest(URLRequest(url: URL(string: "https://" + currenttUrl)!))
    }

    func appendAppInfoToUserAgent() {
        let version: String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let userAgent: String =
            UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")! + " ArhaticYogaJournaliOS-" + version
        UserDefaults.standard.register(defaults: ["UserAgent": userAgent])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest,
                 navigationType: UIWebViewNavigationType) -> Bool {
        if (request.url?.scheme == "tel") {
            // prevents accidental clicks on numbers from being interpreted as "tel:"
            return false
        } else if (request.url?.scheme == "mailto" ||
            ((request.url?.scheme == "http" || request.url?.scheme == "https") && !allowedDomains.contains((request.url?.host!)!))) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(request.url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(request.url!)
            }
            return false
        }

        return true
    }

    func isSignedOut(url: String) -> Bool {
        for (_, element) in signedOutUrlPatterns.enumerated() {
            if (url.contains(element)) {
                return true
            }
        }
        return false
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (scrollView.contentOffset.y < -100) {
            webView.reload()
        }
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        spinner.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        var request: URLRequest = webView.request!

        if ((request.url?.scheme == "http" || request.url?.scheme == "https")) {
            if (request.url?.host != currenttUrl) {
                currenttUrl = (request.url?.host)!
                floaty.removeItem(index: 3)
                floaty.removeItem(index: 2)
                floaty.removeItem(index: 1)
                floaty.removeItem(index: 0)
                buildFloatingActionMenu()
            }

            if (isSignedOut(url: (request.url?.absoluteString)!)) {
                floaty.removeFromSuperview()
            } else {
                self.view.addSubview(floaty)
            }
        }

        spinner.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        spinner.stopAnimating()
    }
}
