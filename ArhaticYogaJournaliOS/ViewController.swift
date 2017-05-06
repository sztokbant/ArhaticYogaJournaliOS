//
//  ViewController.swift
//  ArhaticYogaJournaliOS
//
//  Created by Eduardo Sztokbant on 5/5/17.
//  Copyright © 2017 Eduardo Sztokbant. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var spinner: UIActivityIndicatorView!

    let allowedDomains: Array<String> = ["arhaticnet.herokuapp.com",
                                         "ayj-beta.herokuapp.com",
                                         "ayjournal.herokuapp.com",
                                         "arhaticyogajournal.com"]

    let defaultUrl: String = "https://arhaticnet.herokuapp.com"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        buildSpinner()
        buildWebView()
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
        webView.loadRequest(URLRequest(url: URL(string: defaultUrl)!))
    }

    func appendAppInfoToUserAgent() {
        let version: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
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
        spinner.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        spinner.stopAnimating()
    }
}
